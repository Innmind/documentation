# Design choices

## Core principle

> make it easy to use it right, make it hard to use it wrong

This is achieved by always following the same steps when building any package:
- make it work
- make it simple
- make it fast

> **Note** However the last step is not a priority as there is still plenty of packages to build in order to reach the organization [vision](vision.md). But this doesn't mean speed is sacrified for the sake of simplicity.

## Simplicity

To keep the complexity low, packages use a mix of Functional Programming, Object Oriented Programming and a low usage of primitive types.

Functional Programming allows to increase code robustness and testability by eliminating [side effects](https://en.wikipedia.org/wiki/Side_effect_(computer_science)) and using precise types allowing the use of [static analysis](https://psalm.dev/docs/).

Object Oriented Programming allows to deal with side effects (filesystem, network, etc...) with less convolutions than Functional Programming.

Primitive types (`int`, `string`, etc...) usage is very low as it generally brings too many implicits. [Value Object](https://en.wikipedia.org/wiki/Value_object)s are preferred as they alleviate those implicits.

## Abstractions

To reach the organization [vision](vision.md), abstractions need to compose.

To keep the higher order abstractions complexity low, they use a declarative approach. The APIs focus on what we want to achieve and hides how to achieve it. This allows the abstraction to run in different environments without affecting the user code.

In order to achieve this, the packages use a _capability-based approach_ instead of [ambient authority](https://en.wikipedia.org/wiki/Ambient_authority) (that is generally used in the PHP ecosystem). In other words this means using the [dependency injection](https://en.wikipedia.org/wiki/Dependency_injection) principle for everything outside of the process (time, filesystem, network, etc...).
