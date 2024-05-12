# Explicit

Implicit behaviours makes life easy for small programs. But as it grows and time passes it becomes more and more difficult to remember all of them and make sure they fit together.

Innmind itself is a large project. That's why it tries to be as explicit as possible.

By explicit ear the facts that:

- no code will have unforeseen global behaviour
- no package installation will automatically change a behaviour of a program
- you call Innmind code, not the other way around

This means that to understand your program you can always _go to the definition_ of the function you're using. You can traverse your whole program from entrypoint to low level calls to the system with this approach.

Below you'll find some techniques that make Innmind explicit.

## Parse, don't validate

!!! info ""
    This is a reference to [Alexis King's article](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/).

Validation is the process to check if a value respect a set of rules before using it. Take this example that may feel familiar:

```php
$email = 'foo@example.com';
createUser($email);
sendWelcomeEmail($email);
```

Here both functions have to validate that the `string` passed as argument is indeed an email. The validation has to be done twice because the second function is unaware of the one done in the first function.

Instead Parsing means to attach an information to the validated value. In other words encapsulate your data in an object.

With parsing the example above becomes:

```php
$email = new Email('foo@example.com');
createUser($email);
sendWelcomeEmail($email);
```

Now the validation is done by the `Email` class and will throw if the `string` is not an email. The following functions no longer have to do validation as they're guaranteed to have a valid email as argument.

This is why you'll find a lot of classes in Innmind that only hold data, the classes name are important.

??? note "Exceptions to the rule"
    Note that they're some exceptions to this rule such as the [`Sequence`](../getting-started/handling-data/sequence.md) not having a sister class `NonEmptySequence`. This class doesn't exist because it would make [composition](oop-fp.md#composition) harder.

## Constraints liberate, liberties constrain

!!! info ""
    This is a reference to [Runar Bjarnason's talk](https://www.youtube.com/watch?v=GqmsQeSzMdw).

A constraint prevents us from doing some thing. Liberty is our ability to do what we want.

The saying _constraints liberate, liberties constrain_ then may seem contradictory. Yet us abiding by the law is just that. The law prevents us from harming another citizen, this constraint liberates us from having to worry about someone else trying to harm us and consequently free us to think about more productive activities.

As developers we tend to want to do whatever we want in our programs. But this limits us in the level of abstractions we can use.

Innmind chooses to apply constraints in order to build higher [abstractions](abstractions.md).

### Closed by default

This applies to 2 things: code and data.

For a code to be closed usually means having `final` classes to prevent developer to use inheritance to modify the behaviour of a program, thus encouraging [composition](oop-fp.md#composition). The alternative is the use of functions that can only be composed.

For data this means to be very restrictive when [parsing](#parse-dont-validate).

### Maintainability

By having enough constraints it simplifies the maintainability of this ecosystem.

All possible usages and possible values are known thanks to these constraints, meaning any modification can be safely released.
