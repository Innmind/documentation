# Proofs

A proof[^1] is a way to declare a behaviour for a range of values.

Let's refactor the [previous test](tests.md):

```php hl_lines="4 9 11-16"
use Innmind\BlackBox\{
    Application,
    Runner\Assert,
    Set,
};

Application::new([])
    ->tryToProve(function() {
        yield proof(
            'add',
            given(
                Set\Elements::of(1),
                Set\Elements::of(2),
                Set\Elements::of(3),
            ),
            static fn(Assert $assert, int $a, int $b, int $expected) => $assert
                ->expected($expected)
                ->same(add($a, $b)),
        );
    })
    ->exit();
```

The most important part here is the `Set`s passed to `given`. A `Set` defines a range of values to generate a scenario. In this case we use 3 sets each containing a single value. Each `Set` parameter you add to `given` adds an argument to the test function.

In essence this proof does **exactly** the same thing as the previous test.

Now if we want to generate mutiple scenarii:

```php
use Innmind\BlackBox\{
    Application,
    Runner\Assert,
    Set,
};

Application::new([])
    ->tryToProve(function() {
        yield proof(
            'add',
            given(
                Set\Elements::of(
                    [1, 2, 3],
                    [2, 3, 5],
                ),
            ),
            static function(Assert $assert, array $case) {
                [$a, $b, $expected] = $case;
                $assert
                    ->expected($expected)
                    ->same(add($a, $b));
            }
        );
    })
    ->exit();
```

This proof will run both `add(1, 2) === 3` and `add(2, 3) === 5`. But you don't want to specify all scenarii possible to prove the behaviour of this function.

Instead you'd code the `add` properties like this:

```php
use Innmind\BlackBox\{
    Application,
    Runner\Assert,
    Set,
};

Application::new([])
    ->tryToProve(function() {
        yield proof(
            'add is commutative',
            given(
                Set\Integers::any(),
                Set\Integers::any(),
            ),
            static fn(Assert $assert, int $a, int $b) => $assert->same(
                add($a, $b),
                add($b, $a),
            ),
        );
        yield proof(
            'add is cumulative',
            given(
                Set\Integers::any(),
                Set\Integers::any(),
                Set\Integers::any(),
            ),
            static fn(Assert $assert, int $a, int $b, int $c) => $assert->same(
                add($a, add($b, $c)),
                add(add($a, $b), $c),
            ),
        );
        yield proof(
            '0 is an identity value',
            given(Set\Integers::any()),
            static fn(Assert $assert, int $a) => $assert->same(
                $a,
                add($a, 0), #(1)
            ),
        );
    })
    ->exit();
```

1. Where `0` is placed doesn't matter thanks to the commutative proof above.

Each time you'll run these proofs BlackBox will run `100` scenarii per proof with different values each time. This way the more you run these proofs the more BlackBox the _values space_ to try a specific combination that makes the `add` function fail.

You should explore the `Innmind\BlackBox\Set\` namespace to see all the values you can generate. `Set`s can be composed so you're not limited to primitive values, you can build pretty much any data structure.

??? tip
    Other packages can also expose `Set`s, you can find them on Packagist via the [`innmind/black-box-sets` virtual package](https://packagist.org/providers/innmind/black-box-sets).

[^1]: BlackBox use the term _proof_ to emphasize that you are testing behaviours not specific scenarii, but these are **NOT** [formal proofs](https://en.wikipedia.org/wiki/Formal_proof).
