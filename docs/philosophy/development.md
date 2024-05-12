# Development Process

## Type strictness

All packages use [Psalm](https://psalm.dev) on the strictess level to make sure there won't be type errors.

To make sure you use Innmind correctly you should use it as well.

## Versioning

All packages use [Semver](https://semver.org) to release new versions.

All minor and bugfix versions are retro compatible and try as mush as possible to not change your program's behaviour. Most updates bring new code that you have to choose to use it (or not).

Major updates break the API.

Changelogs and the type system will help you through all changes.

## Make it easy to use it right

> and make it difficult to use it wrong.

This summarizes all the previous chapters.

To reach this all packages go through the same iteration loop:

- make it work
- make it simple
- make it fast

??? note
    Though the last step has a lower priority than building new higher level [abstractions](abstractions.md).
