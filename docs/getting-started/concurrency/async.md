# Asynchronous code

Since Innmind offers to access all I/O operations through the [operating system abstraction](../operating-system/index.md), it can easily execute these operations asynchronously.

## Installation

```sh
composer require innmind/mantle:~2.1
```

## Usage

Mantle works a bit like a reduce operation. The _reducer_ function allows to launch `Task`s and react to their results. Both the _reducer_ and tasks are run asynchronously.

=== "Reducer"
    ```php
    use Innmind\Mantle\Forerunner;
    use Innmind\Http\Response;
    use Innmind\Immutable\Sequence;

    $run = Forerunner::of($os);
    $responses = $run(
        Carried::new(),
        new Reducer,
    );
    $responses; // instance of Sequence<?Response>
    ```

=== "Carried value"
    Like in a real reduce operation you need a carried value that will be passed to the reducer every time it's called.

    Here we use a `Carried` class but you can use any type you wish.

    ```php
    use Innmind\Http\Response;
    use Innmind\Immutable\Sequence;

    final readonly class Carried
    {
        /** @var Sequence<?Response> */
        private function __construct(
            private bool $tasksLaucnhed,
            private Sequence $responses,
        ) {}

        public static function new(): self
        {
            return new self(false, Sequence::of());
        }

        public function tasksLaunched(): self
        {
            return new self(true, $this->responses);
        }

        public function needsToLaunchTasks(): bool
        {
            return !$this->tasksLaunched;
        }

        public function got(?Response $response): self
        {
            return new self(
                $this->tasksLaunched,
                $this->responses->add($response),
            );
        }

        /** @return Sequence<?Response> */
        public function responses(): Sequence
        {
            return $this->responses;
        }
    }
    ```

    !!! warning ""
        To avoid unexpected side effects you should always use an immutable value for the carried value.

=== "Reducer"
    ```php
    use Innmind\Mantle\{
        Source\Continuation,
        Task,
    };
    use Innmind\OperatingSystem\OperatingSystem;
    use Innmind\Http\Response;
    use Innmind\Immutable\Sequence;

    final class Reducer
    {
        /**
         * @param Continuation<Carried> $continuation
         * @param Sequence<?Response> $results
         *
         * @return Continuation<Carried>
         */
        public function __invoke(
            Carried $carried,
            OperatingSystem $os, #(1)
            Continuation $continuation,
            Sequence $results, #(2)
        ): Continuation {
            if ($carried->needsToLaunchTasks()) {
                return $continuation
                    ->carryWith($carried->tasksLaunched()) #(3)
                    ->launch(Sequence::of(
                        Task::of( #(4)
                            static fn(OperatingSystem $os) => MyTask::of(
                                $os,
                                'https://github.com/'
                            ),
                        ),
                        Task::of(
                            static fn(OperatingSystem $os) => MyTask::of(
                                $os,
                                'https://gitlab.com/'
                            ),
                        ),
                    ));
            }

            $carried = $results->reduce(
                $carried,
                static fn(
                    Carried $carried,
                    ?Response $response
                ) => $carried->got($response),
            );

            if ($carried->responses()->size() === 2) {
                return $continuation
                    ->carryWith($carried)
                    ->terminate(); #(5)
            }

            return $continuation->carryWith($carried);
        }
    }
    ```

    1. This `$os` variable is a new instance built by Mantle and runs asynchronously.
    2. This will contain the values returned by the tasks as soon as available.
    3. We flip the flag in order to not launch the tasks each time the reducer is called.
    4. The `$os` variable below is a dedicated new instance for each task.
    5. This tells Mantle to stop calling the reducer and return the carried value.

    This `__invoke` method will be called once when starting the runner and then each time a task finishes.

    The flag to know if the tasks have been launched is stored in the carried value, but since we're in an object it could be placed as a property. This is done so you can better differentiate the carried values from the `$results` in this example.

=== "MyTask"
    ```php
    use Innmind\OperatingSystem\OperatingSystem;
    use Innmind\Http\{
        Request,
        Response,
        Method,
        ProtocolVersion,
    };
    use Innmind\Url\Url;

    final class MyTask {
        public static function of(
            OperatingSystem $os,
            string $url,
        ): ?Response {
            return $os
                ->remote()
                ->http()(Request::of(
                    Url::of($url),
                    Method::get,
                    ProtocolVersion::v11,
                ))
                ->match(
                    static fn(Success $success) => $success->response(),
                    static fn() => null,
                );
        }
    }
    ```


## Advantages

The first big advantage of this design is that your task is completely unaware that it is run asynchronously. It all depends on the `$os` variable inject (1). This means that you can easily experiment a piece of your program in an async context by what code calls it, your program logic itself doesn't have to change!
{.annotate}

1. If it comes from Mantle it's async otherwise it's sync.

The side effect of this is that you can test your code synchronously even though it's run asynchronously.

The other advantage is that since all state is local you can compose async code inside sync code transparently. You can't affect a global state since there is none.

## Limitations

- CLI signals are currently not supported in this context
- HTTP calls are currently done via `cURL` and uses micro sleeps instead of watching sockets
- SQL queries are still run synchronously for now
- It seems there is a limit of 10k concurrent tasks before performance degradation

Most of these limitations are planned to be fixed in the future.

!!! warning ""
    You may not want to use this in production just yet, or at least for mission critical code.
