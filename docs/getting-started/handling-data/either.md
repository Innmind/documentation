# Either

The `Either` monad always represents a value but it's either on a _right side_ or _left side_.

If you've understood [`Maybe`](maybe.md), it's an `Either` with the `Maybe` value on the _right side_ or `null` as the value on the _left side_.

In essence:
```php
use Innmind\Immutable\Either;

$right = Maybe::just(42);
$left = Maybe::nothing();
// becomes
$right = Either::right(42);
$left = Either::left(null);
```

It is usually used to express a value for a nominal case on the right side and the errors that may occur on the left side. This means that it replaces the use of `Exception`s.

Each example will show how to use `Either` and the imperative equivalent in plain old PHP via `Exception`s.

??? tip
    This is because `Maybe` and `Either` are very similar that you can switch for one type to another via `$maybe->either()` (1) or `$either->maybe()` (2).
    {.annotate}

    1. then the left side is `null`
    2. the left value is thrown away

## Usage

Let's say you want to create a user from an email and the function must fail in case the email already exist. You could do:

=== "Innmind"
    ```php
    /**
     * @return Either<EmailAlreadyUsed, User>
     */
    function createUser(string $email, string $name): Either {
        if (/* some condition to check if email is already known*/) {
            return Either::left(new EmailAlreadyUsed);
        }

        /* code to insert the user in a db */
        $user = new User($email, $name);

        return Either::right($user);
    }

    createUser('foo@example.com', 'John Doe')->match(
        static fn(User $user) => doStuff($user),
        static fn(EmailAlreadyUsed $error) => doOtherStuff(),
    );
    ```

=== "Imperative"
    ```php
    /**
     * @throws EmailAlreadyUsed
     * @return User
     */
    function createUser(string $email, string $name): User {
        if (/* some condition to check if email is already known*/) {
            throw new EmailAlreadyUsed;
        }

        /* code to insert the user in a db */
        $user = new User($email, $name);

        return $user;
    }

    try {
        $user = createUser('foo@example.com', 'John Doe');
        doStuff($user);
    } catch (EmailAlreadyUsed $e) {
        doOtherStuff();
    }
    ```

Here we use a `string` to represent an email, instead [we should use an object](../../philosophy/explicit.md#parse-dont-validate) to abstract it to make sure the value is indeed an email.

=== "Innmind"
    ```php
    final class Email
    {
        /**
         * @return Either<InvalidEmail, self>
         */
        public static function of(string $value): Either
        {
            if (/* check value */) {
                return Either::right(new self($value));
            }

            return Either::left(new InvalidEmail);
        }
    }

    Email::of('foo@example.com')
        ->flatMap(static fn(Email $email) => createUser($email, 'John Doe'))
        ->match(
            static fn(User $user) => doStuff($user),
            static fn(InvalidEmail | EmailAlreadyUsed $error) => doOtherStuff(),
        );
    ```

=== "Imperative"
    ```php
    final class Email
    {
        /**
         * @throws InvalidEmail
         * @return self
         */
        public static function of(string $value): self
        {
            if (/* check value */) {
                return new self($value);
            }

            throw new InvalidEmail;
        }
    }

    try {
        $email = Email::of('foo@example.com');
        $user = createUser($email, 'John Doe');
        doStuff($user);
    } catch (InvalidEmail | EmailAlreadyUsed $e) {
        doOtherStuff();
    }
    ```

!!! success ""
    Both approaches seem very similar but there's a big advantage to `Either`: a static analysis tool understand the flow of errors and can tell you if when calling `match` you don't handle all possible error values. No tool can help you do the same with exceptions.

Just like `Maybe` you can recover in case of an error via the `otherwise` method. For example in the case the email is already used, instead of failing we can decide to update the stored user.

=== "Innmind"
    ```php
    Email::of('foo@example.com')
        ->flatMap(
            static fn(Email $email) => createUser($email, 'John Doe')->otherwise(
                static fn(EmailAlreadyUsed $error) => updateUser($email, 'John Doe'),
            ),
        )
        ->match(
            static fn(User $user) => doStuff($user),
            static fn(InvalidEmail $error) => doOtherStuff(),
        );
    ```

=== "Imperative"
    ```php
    try {
        $email = Email::of('foo@example.com');

        try {
            $user = createUser($email, 'John Doe');
        } catch (EmailAlreadyUsed $e) {
            $user = updateUser($email, 'John Doe');
        }

        doStuff($user);
    } catch (InvalidEmail $e) {
        doOtherStuff();
    }
    ```

In all examples you've seen the use of `flatMap` but you can also use the `map` to modify the value on the right side. And there's a `leftMap` to modify the value on the left side.

## In the ecosystem

`Either` is used when an action may have multiple cases of errors that you should handle, such as [HTTP calls](../operating-system/http.md) or when working with [queues](../concurrency/queues.md).

But the beauty is that if you don't want to deal with the different errors you can throw them away by converting the `Either` to a `Maybe` via `$either->maybe()`.

Like `Maybe` and `Sequence` is has a [deferred mode](sequence.md#deferred) that allows to postpone some actions as you'll see in the [concurrent HTTP calls section](../concurrency/http.md).
