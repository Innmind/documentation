---
authors: [baptouuuu]
date: 2024-06-29
---

# Living a simpler lazy life

The [`Sequence`](../../getting-started/handling-data/sequence.md) monad is very powerful as it allows you to switch from an in memory strategy to a lazy one by only modifying the constructor, the rest of the program is unchanged.

However composing correctly lazy `Sequence`s has been challenging... until now!

<!-- more -->

To better describe the problem let's use this function that builds an [xml file](../../packages.md#xml):

```php
use Innmind\Filesystem\File\Content;
use Innmind\Xml\{
    Node\Document,
    Node\Text,
    Element\Element,
};
use Innmind\Immutable\{
    Sequence,
    Maybe,
};

/**
 * @param Sequence<string> $entries
 */
function build(Sequence $entries): Content
{
    $xml = Document::of(
        Document\Version::of(1, 0)
        Maybe::nothing(),
        Maybe::just(Document\Encoding::of('utf-8')),
        Sequence::of(
            Element::of(
                'log',
                null,
                Sequence::of(
                    Element::of(
                        'entries',
                        null,
                        $entries
                            ->map(Text::of(...))
                            ->map(Sequence::of(...))
                            ->map(static fn(Sequence $children) => Element::of(
                                'entry',
                                null,
                                $children,
                            )),
                    ),
                ),
            ),
        ),
    );

    return $xml->asContent();
}
```

When run this code would produce an xml file like:

```xml
<?xml version="1.0"?>
<log>
    <entries>
        <entry>entry-1</entry>
        <entry>entry-2</entry>
        <entry>etc...</entry>
    </entries>
</log>
```

Internally the `$xml->asContent()` will flatten the nesting of elements to a single `Sequence` containing each line of the file.

If you don't have many entries this will work fine. But if you know you'll have to handle a number of entries that can't fit in memory you'll use a lazy `Sequence` for `$entries`.

The `build` function will fail in this case with an _out of memory_ error. The problem lies with the `Sequence`s used for the `Document` and `log` children, we use the `::of()` constructor meaning _in memory_. So when the elements are flattened it will keep everything in memory.

A simple fix would be to replace `::of()` by `::lazyStartingWith()` like so:

```php hl_lines="7 11"
function build(Sequence $entries): Content
{
    $xml = Document::of(
        Document\Version::of(1, 0)
        Maybe::nothing(),
        Maybe::just(Document\Encoding::of('utf-8')),
        Sequence::lazyStartingWith(
            Element::of(
                'log',
                null,
                Sequence::lazyStartingWith(
                    Element::of(
                        'entries',
                        null,
                        $entries
                            ->map(Text::of(...))
                            ->map(Sequence::of(...))
                            ->map(static fn(Sequence $children) => Element::of(
                                'entry',
                                null,
                                $children,
                            )),
                    ),
                ),
            ),
        ),
    );

    return $xml->asContent();
}
```

This indeed fixes the problem but it brings new ones.

The first one is that even if you use an in memory `Sequence` for the entries the file is still lazy. This complexifies debugging and testing because internally it uses generators and the stack traces are harder to read.

But the main problem is about [implicits](../../philosophy/explicit.md). When creating the function you have to know if the data you handle is lazy or not. This is tricky because you can get it wrong or even forget to check and it will crash in production. But even if you get it right nothing prevents someone in the future to use the function with a lazy `Sequence` while it was designed for in memory usage. And once again it will crash in production.

!!! success ""
    Thanks to [`innmind/immutable` `5.8`](https://github.com/Innmind/Immutable/releases/tag/5.8.0) this problem no longer have to exist.

The solution is to start with the input data that may or may not be lazy and compose it through the `Identity` monad. With this the function becomes:

```php
function build(Sequence $entries): Content
{
    return $entries
        ->map(Text::of(...))
        ->map(Sequence::of(...))
        ->map(static fn(Sequence $children) => Element::of(
            'entry',
            null,
            $children,
        ))
        ->toIdentity()
        ->map(static fn(Sequence $entries) => Element::of(
            'entries',
            null,
            $entries,
        ))
        ->toSequence()
        ->toIdentity()
        ->map(static fn(Sequence $entries) => Element::of(
            'log',
            null,
            $entries,
        ))
        ->toSequence()
        ->toIdentity()
        ->map(static fn(Sequence $log) => Document::of(
            Document\Version::of(1, 0)
            Maybe::nothing(),
            Maybe::just(Document\Encoding::of('utf-8')),
            $log,
        ))
        ->unwrap()
        ->asContent();
}
```

If the input is a lazy `Sequence` then a call to `toIdentity` will create a lazy `Identity` and a call to `toSequence` will create a lazy `Sequence` (because the identity itself is lazy), thus the whole operation is lazy. On the other hand if the input is an in memory `Sequence` then the whole operation will be as well.

!!! abstract ""
    In some sense the implementation of the function adapts itself to the need of its caller.

The following packages have already been updated to allow this design:

- [`innmind/amqp`](https://github.com/Innmind/AMQP/releases/tag/5.1.0)
- [`innmind/encoding`](https://github.com/Innmind/encoding/releases/tag/1.1.0)
- [`innmind/html`](https://github.com/Innmind/Html/releases/tag/6.4.0)
- [`innmind/xml`](https://github.com/Innmind/XML/releases/tag/7.7.0)

??? tip "Going further"
    The examples above use the [`innmind/xml`](../../packages.md#xml) package. If you're not familiar with it it may be difficult to understand what's really happening. Let's break it down!

    The initial implementation with only `Sequence`s would look like this:

    ```php
    use Innmind\Filesystem\File\Content;
    use Innmind\Immutable\{
        Sequence,
        Str,
    };

    /**
     * @param Sequence<string> $entries
     */
    function build(Sequence $entries): Content
    {
        $xml = Sequence::of('<?xml version="1.0"?>')->append(
            Sequence::of('<log>')
                ->append(
                    Sequence::of('<entries>')
                        ->append(
                            $entries
                                ->map(static fn(string $entry) => \sprintf(
                                    '<entry>%s</entry>'
                                    $entry,
                                ))
                                ->map(static fn(string $line) => '    '.$line),
                        )
                        ->add('</entries>')
                        ->map(static fn(string $line) => '    '.$line),
                )
                ->add('</log>'),
        );

        return Content::ofLines(
            $xml
                ->map(Str::of(...))
                ->map(Content\Line::of(...)),
        );
    }
    ```

    Before `innmind/immutable` `5.7` this is the best we could do. `5.7` introduced the `Sequence::prepend()` method.

    ```php hl_lines="6-12"
    function build(Sequence $entries): Content
    {
        $xml = Sequence::of('<?xml version="1.0"?>')->append(
            Sequence::of('<log>')
                ->append(
                    $entries
                        ->map(static fn(string $entry) => \sprintf(
                            '<entry>%s</entry>'
                            $entry,
                        ))
                        ->map(static fn(string $line) => '    '.$line)
                        ->prepend(Sequence::of('<entries>')),
                        ->add('</entries>'),
                        ->map(static fn(string $line) => '    '.$line),
                )
                ->add('</log>'),
        );

        return Content::ofLines(
            $xml
                ->map(Str::of(...))
                ->map(Content\Line::of(...)),
        );
    }
    ```

    `prepend` allows us to remove one level of nesting, but we still have the top `Sequence` that only works in memory.

    To fix it is to use `prepend` once more:

    ```php hl_lines="12-14"
    function build(Sequence $entries): Content
    {
        $xml = $entries
            ->map(static fn(string $entry) => \sprintf(
                '<entry>%s</entry>'
                $entry,
            ))
            ->map(static fn(string $line) => '    '.$line)
            ->prepend(Sequence::of('<entries>'))
            ->add('</entries>')
            ->map(static fn(string $line) => '    '.$line)
            ->prepend(Sequence::of('<log>'))
            ->add('</log>')
            ->prepend(Sequence::of('<?xml version="1.0"?>'));

        return Content::ofLines(
            $xml
                ->map(Str::of(...))
                ->map(Content\Line::of(...)),
        );
    }
    ```

    As a single _pipeline_ this may be difficult to read, but we can break it up like this without changing what's happening:

    ```php
    function build(Sequence $entries): Content
    {
        $entries = $entries->map(static fn(string $entry) => \sprintf(
            '<entry>%s</entry>'
            $entry,
        ));
        $entriesTag = $entries
            ->map(static fn(string $line) => '    '.$line)
            ->prepend(Sequence::of('<entries>'))
            ->add('</entries>');
        $log = $entriesTag
            ->map(static fn(string $line) => '    '.$line)
            ->prepend(Sequence::of('<log>'))
            ->add('</log>');
        $xml = $log->prepend(Sequence::of('<?xml version="1.0"?>'));

        return Content::ofLines(
            $xml
                ->map(Str::of(...))
                ->map(Content\Line::of(...)),
        );
    }
    ```

    As you may have noticed in this section we didn't have to use `Identity`. That's because we didn't have to wrap each `Sequence` in another object, it's this kind of wrappers that prevent direct composition of the `Sequence`s.

    ---

    If you're familiar with PHP _the imperative way_ you may think all this is overengineered. You could write something like this and call it a day:

    ```php
    /**
     * @param iterable<string> $entries
     * @return iterable<string>
     */
    function build(iterable $entries): iterable
    {
        yield '<?xml version="1.0"?>';
        yield '<log>';
        yield '    <entries>';

        foreach ($entries as $entry) {
            yield \sprintf(
                '        <entry>%s</entry>',
                $entry,
            );
        }

        yield '    </entries>';
        yield '</log>';
    }
    ```

    At first glance this is simpler and easier to read. But this brings numerous problems:

    - the whole program has to use generators
    - if not foreseen this will require everything to be rewritten with generators
    - pseudo-type `iterable` let you think you can reuse the collection which may not be the case
    - it forces a caller to be aware of the implementation
    - someone using an `iterator_to_array` on the output of `build` may result in an _out of memory_ error
        - this can be easily overlooked when reviewing the code
    - it loses the ability to [run asynchronously](../../getting-started/concurrency/async.md)
    - and I'm sure more can be found...
