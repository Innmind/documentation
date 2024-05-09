# Inter Process Communication

When your program runs across multiple processes you may want to communicate between them to update some state.

Innmind IPC use unis sockets to send messages between processes.

## Installation

```sh
composer require innmind/ipc:~4.4
```

## Usage

=== "Server"
    ```php
    use Innmind\IPC\{
        Factory,
        Process\Name,
        Message,
        Continuation,
    };

    $ipc = Factory::of($os);
    $serve = $ipc->listen(Name::of('server-name'));
    $counter = $serve(
        0, #(1)
        static function(
            Message $message,
            Continuation $continuation,
            int $counter, #(2)
        ): Continuation {
            if ($counter === 42) {
                return $continuation->stop($counter);
            }

            return $continuation->respond(
                $counter + 1, #(3)
                Message\Generic::of('text/plain', 'pong'),
            );
        },
    )->match(
        static fn(int $counter) => $counter,
        static fn() => throw new \RuntimeException('Unable to start the server'),
    );
    ```

    1. This is the initial carried value.
    2. This is the carried value between every call of the function.
    3. This updates the carried value for the next message.

    The server behaves like a reduce operation, with a carried value and a function that's called every time a client sends a message. The carried value can be of any type.

    In this case the server will stop after receiving `42` messages.

    The returned value is an [`Either`](../handling-data/either.md) with the carried value on the right side or an error on the left side if the server failed to start.

=== "Client"
    ```php
    use Innmind\IPC\{
        Factory,
        Process,
        Process\Name,
        Message,
    };

    $ipc = Factory::of($os);
    $ipc
        ->wait(Name::of('server-name'))
        ->flatMap(fn(Process $process) => $process->send(Sequence::of(
            Message\Generic::of('text/plain', 'ping'),
        )))
        ->flatMap(fn(Process $process) => $process->wait())
        ->match(
            static fn(Message $message) => print(
                'server responded '.$message->content()->toString(),
            ),
            static fn() => print('no response from the server'),
        );
    ```

    This will wait for the server to be up then it will send a `ping` message and wait for the server to respond. Then it will print `server responded pong` since the server always repond with this message unless it has stopped in the meantime.

    ??? tip
        If you want to immediately stop if the server is not up you can replace `$ipc->wait()` by `$ipc->get()`.
