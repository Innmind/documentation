# Wait for a server to start

Let's say you want to start the PHP HTTP server to starting sending requests to it. Before sending requests you need to make sure it's up.

You can do so with:

```php
use Innmind\Server\Control\Server\Command;
use Innmind\Immutable\Str;

$process = $os
    ->control()
    ->processes()
    ->execute(
        Command::foreground('php')
            ->withShortOption('S')
            ->withArgument('localhost:8080'),
    );
$process
    ->output()
    ->chunks()
    ->map(static fn(array $chunk) => $chunk[0])
    ->takeWhile(static fn(Str $chunk) => !$chunk->contains('started'))
    ->memoize();

// you can send requests here
```

The `memoize` call is important because it's at this point that it will wait for an output chunk to contain the `started` text. Since by default the output use a [deferred `Sequence`](../getting-started/handling-data/sequence.md#deferred) without the `memoize` it would do nothing (as if the code wasn't there at all).
