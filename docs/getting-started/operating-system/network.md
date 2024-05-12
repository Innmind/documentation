# Network

## Unix socket

If you look to communicate between processes you should head to the [IPC chapter](../concurrency/ipc.md).

### Server

The first part to build a socket server is to accept incoming connections at an address:

```php
use Innmind\IO\Sockets\Server;
use Innmind\Socket\Address\Unix;
use Innmind\Immutable\Sequence;

$server = $os
    ->sockets()
    ->open(Unix::of('/tmp/some-socket-name'))
    ->match(
        static fn(Server $server) => $server,
        static fn() => throw new \RuntimeException('Failed to open socket'),
    );
$clients = Sequence::of();

while (true) {
    $clients = $server
        ->watch()
        ->accept()
        ->toSequence()
        ->append($clients);
}
```

This will wait forever for a connection to open, when it does it's added to `$clients` and then resume watching for new connections.

The next step is to define a protocol. Let's take a silly example where when connecting a client must send `hello world\n` followed by their message ending with `\n`. You can define such protocol like this:

```php
use Innmind\IO\Readable\Frame\{
    Chunk,
    Line,
};
use Innmind\Immutable\Str;

$protocol = Chunk::of(12)
    ->flatMap(static fn(Str $hello) => Line::new())
    ->map(Str $message) => $message->rightTrim("\n"));
```

`Chunk::of(12)` expresses the expected hello world string. `flatMap` expresses what to do next with the read value, in this case we tell that we want a line ending with `\n`. `map` transform the line read previously to remove the `\n` at the end since it's not part of the message.

??? info
    You can explore the `Innmind\IO\Readable\Frame\` namespace to see the other kind of frames you can use. And you can also define your own.

    You can look at [`innmind/http-parser`](https://github.com/Innmind/http-parser) or [`innmind/amqp`](https://github.com/Innmind/AMQP) for concrete examples of protocols defined this way.

??? tip
    Here the `map` only modifies the message but you can change the value to any type you wish. It's even encouraged to encapsulate the data in your own classes to make sure it's the format you expect.

You can use then the procol like this:

```php hl_lines="11-12"
use Innmind\IO\Sockets\Client;
use Innmind\Immutable\Str;

$server
    ->watch()
    ->accept()
    ->flatMap(
        static fn(Client $client) => $client
            ->toEncoding(Str\Encoding::ascii)
            ->watch()
            ->frames($protocol)
            ->one(),
    )
    ->match(
        static fn(Str $message) => $message,
        static fn() => null, // either no connection or failed to read the message
    );
```

Sending data to the incoming connection is the same way as from the client side ([see below](#client)).

### Client

To connect to a server you can do:

```php
use Innmind\IO\Sockets\Client;
use Innmind\Socket\Address\Unix;

$client = $os
    ->sockets()
    ->connectTo(Unix::of('/tmp/some-socket-name'))
    ->match(
        static fn(Client $client) => $client,
        static fn() => throw new \RuntimeException('Failed to connect'),
    );
```

Then to send data:

```php
use Innmind\Immutable\{
    Str,
    Sequence,
};

$client
    ->toEncoding(Str\Encoding::ascii)
    ->send(Sequence::of(
        Str::of("hello world\nThis is your message\n"),
    ))
    ->match(
        static fn() => null, // message sent
        static fn() => throw new \RuntimeException('Failed to send'),
    );
```

??? info
    As you can see `send` expect a `Sequence` of messages meaning you can send multiple ones. This is so you don't have to loop yourself.

    In case you use a lazy sequence and you want to abort midway (say because a [signal tells you to stop](php-process.md#handling-cli-signals)), you can do it like this:

    ```php
    $signaled = false;
    $client
        ->abortWhen(static function() use (&$signaled) {
            return $signaled;
        })
        ->send($messages)
        ->match(
            static fn() => null, // message sent
            static fn() => throw new \RuntimeException('Failed to send'),
        );
    ```

    If the sending is aborted then it will always reach the error case, here meaning it will throw the exception.

If you want to read data coming from the server you'd do it the same way the server does ([see above](#server)).

## Over the wire

This works exactly the same way as unix sockets except for the method to open the server and the method to connect to it:

=== "Open server"
    ```php
    use Innmind\IO\Sockets\Server;
    use Innmind\Socket\Internet\Transport;
    use Innmind\IP\IP;
    use Innmind\Url\Authority\Port;

    $server = $os
        ->ports()
        ->open(
            Transport::tcp(),
            IP::v4('0.0.0.0'),
            Port::of(8080),
        )
        ->match(
            static fn(Server $server) => $server,
            static fn() => throw new \RuntimeException(),
        );
    ```

=== "Open connection"
    ```php
    use Innmind\IO\Sockets\Client;
    use Innmind\Socket\Internet\Transport;
    use Innmind\Url\Url;

    $client = $os
        ->remote()
        ->socket(
            Transport::tcp(),
            Url::of('tcp://machine-ip:8080/')->authority(),
        )
        ->match(
            static fn(Client $client) => $client,
            static fn() => throw new \RuntimeException(),
        );
    ```
