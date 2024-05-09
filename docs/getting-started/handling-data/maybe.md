# Maybe

A `Maybe` monad represents the possible absence of a value.

This is an equivalent of a nullable value, but a more faithful representation would be an `array` containing 0 or 1 value.

In essence:
```php
use Innmind\Immutable\Maybe;

$valueExist = 42;
$valueDoesNotExist = null;
// or
$valueExist = [42];
$valueDoesNotExist = [];
// becomes
$valueExist = Maybe::just(42);
$valueDoesNotExist = Maybe::nothing();
```

Each example will show how to use `Maybe` and the imperative equivalent in plain old PHP (1).
{.annotate}

1. The nullable approach is used as it's the dominant approach in PHP programs.

## Usage

=== "Innmind"
    ```php
    /**
     * @return Maybe<User>
     */
    function getUser(int $id): Maybe {
        return match ($id) {
            42 => Maybe::just(new User),
            default => Maybe::nothing(),
        };
    }
    ```

=== "Imperative"
    ```php
    function getUser(int $id): ?User {
        return match ($id) {
            42 => new User,
            default => null,
        };
    }
    ```

In this function we represent the fact that they're may be not a `User` (1) for every id. To work with the user, if there's any, you would do:
{.annotate}

1. This is a fake class.

=== "Innmind"
    ```php
    getUser(42)->match(
        static fn(User $user) => doStuff($user),
        static fn() => userDoesntExist(),
    );
    ```

=== "Imperative"
    ```php
    match ($user = getUser(42)) {
        null => userDoesntExist(),
        default => doStuff($user),
    };
    ```

As you can see the 2 approaches are very similar for now.

In this example the user is directly used as an argument to a function but we often want to extract some data before calling some function. A use case could be to extract the brother id out of this user (1) and call again our function.
{.annotate}

1. Via a method `#!php function getBrotherId(): int`.

=== "Innmind"
    ```php
    getUser(42)
        ->map(static fn(User $user) => $user->getBrotherId())
        ->flatMap(static fn(int $id) => getUser($id))
        ->match(
            static fn(User $brother) => doStuff($brother),
            static fn() => brotherDoesNotExist(),
        );
    ```

=== "Imperative"
    ```php
    $user = getUser(42);

    if (\is_null($user)) {
        brotherDoesNotExist();

        return;
    }

    $brother = getUser($user->getBrotherId());

    if (\is_null($brother)) {
        brotherDoesNotExist();

        return;
    }

    doStuff($brother);
    ```

This example introduces the `map` and `flatMap` methods. They behave the same way as their `Sequence` counterpart.

- `map` will apply the function in case the `Maybe` contains a value
- `flatMap` is similar to `map` except that the function passed to it must return a `Maybe`, instead of having the return type `Maybe<Maybe<User>>` (1) you'll have a `Maybe<User>`
{.annotate}

    1. as you would by using `map` instead of `flatMap`

What this example shows is that with `Maybe` you only need to deal with the possible absence of the data when you extract it. While with the imperative style you need to deal with it each time you call a function.

This becomes even more flagrant if the method that returns the brother id itself may not return a value (1). The signature becomes `#!php function getBrotherId(): Maybe<int>`.
{.annotate}

1. as one may not have one

=== "Innmind"
    ```php hl_lines="2"
    getUser(42)
        ->flatMap(static fn(User $user) => $user->getBrotherId()) #(1)
        ->flatMap(static fn(int $id) => getUser($id))
        ->match(
            static fn(User $brother) => doStuff($brother),
            static fn() => brotherDoesNotExist(),
        );
    ```

    1. This is the only change, `map` is replaced by `flatMap` do deal with the possible absence.

=== "Imperative"
    ```php hl_lines="9-15"
    $user = getUser(42);

    if (\is_null($user)) {
        brotherDoesNotExist();

        return;
    }

    $brotherId = $user->getBrotherId();

    if (\is_null($brotherId)) {
        brotherDoesNotExist();

        return;
    }

    $brother = getUser($brotherId);

    if (\is_null($brother)) {
        brotherDoesNotExist();

        return;
    }

    doStuff($brother);
    ```

So far we _do nothing_ in case our user doesn't have a brother. But what if we want to check if he has a sister in case he doesn't have a brother ? `Maybe` has an expressive way to describe such case:

=== "Innmind"
    ```php hl_lines="5"
    getUser(42)
        ->flatMap(
            static fn(User $user) => $user
                ->getBrotherId()
                ->otherwise(static fn() => $user->getSistserId()),
        )
        ->flatMap(static fn(int $id) => getUser($id))
        ->match(
            static fn(User $sibling) => doStuff($sibling),
            static fn() => brotherDoesNotExist(),
        );
    ```

=== "Imperative"
    ```php hl_lines="9"
    $user = getUser(42);

    if (\is_null($user)) {
        brotherDoesNotExist();

        return;
    }

    $siblingId = $user->getBrotherId() ?? $user->getSisterId();

    if (\is_null($siblingId)) {
        brotherDoesNotExist();

        return;
    }

    $sibling = getUser($siblingId);

    if (\is_null($sibling)) {
        brotherDoesNotExist();

        return;
    }

    doStuff($sibling);
    ```

## In the ecosystem

`Maybe` is used to express the abscence of data (1) or the possible failure of an operation (2). For the latter it is expressed via `Maybe<Innmind\Immutable\SideEffect>`, meaning if it contains a `SideEffect` the operation as succeeded otherwise it failed.
{.annotate}

1. Such as the absence of a [file on the filesystem](../operating-system/filesystem.md) or the absence of an [entity from a storage](../orm/index.md).
2. Such as failing to [upload a file to an S3 bucket](https://github.com/Innmind/S3)

It also as a [deferred mode like `Sequence`](sequence.md#deferred) that allows to not directly load in memory a value when you call `$sequence->get($index)`. The returned `Maybe` in this case will load the value when you call the `match` method.
