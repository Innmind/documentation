# Semantic

## The aim

A good semantic allows to communicate an idea quickly by _compressing the information_. For example, the word _cat_ caries a lot more information and in a more comprehensive way than _a set of atoms forming a small 4 legged animal with whiskers_.

By establishing a good vocabulary it's possible to convey more and more complex information in a relatively constant space.

## This is not code

```php
$os
    ->filesystem()
    ->mount(Path::of('folder/'))
    ->unwrap()
    ->get(Name::of('file'))
    ->keep(Instance::of(File::class))
    ->match(
        static fn(File $file) => $file
            ->content()
            ->lines()
            ->foreach(static fn(Line $line) => echo $line->toString()),
        static fn() => echo 'unknown file',
    );
```

With this example we see that it's possible to understand the result of a program without knowing how it is executed.

Code was initially a way to tell the machine the steps to follow to reach a result. But the more we move up through the abstractions (languages included) the farther away we get to tell the machine the exact steps.

The more the abstractions the more we need to communicate with other developers in order to build programs.

Code is now a formalised language between humans that has the side effect of being runnable by machines.

## Declarative

Imperative code is telling the machine **how** to do things. While Declarative is telling **what** to do.

A concrete example of this is the difference between an `array` and the [`Sequence` monad](../getting-started/handling-data/sequence.md). With an array it's easy to handle data as it's assigning values for indices, but it's not possible to handle an infinite stream of values (as it requires to use generators). On the other hand the `Sequence` only allows to describe the transitions the values must follow, you have no say on the way the values are assigned internally.

This allows the `Sequence` to have multiple internal representations. It can work just like an `array` with the same assignment logic, or it can work with an infinite stream of values. The choice lies with the one creating the `Sequence`, any use of it is the same afterward.

It's by this mechanism that this ecosystem can grow while keeping the complexity under control.
