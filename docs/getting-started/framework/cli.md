# CLI

## Usage

The first step is to define the entrypoint:

```php title="bin/console"
<?php
declare(strict_types = 1);

require 'path/to/composer/autoload.php';

use Innmind\Framework\{
    Main\Cli,
    Application,
};

new class extends Cli {
    protected function configure(Application $app): Application
    {
        return $app;
    }
};
```

If you run `php bin/console` it will print `Hello world`.

You can specify a command like so:

```php title="bin/console"
use Innmind\CLI\{
    Console,
    Command,
};
use Innmind\Immutable\Str;

new class extends Cli {
    protected function configure(Application $app): Application
    {
        return $app->command(
            static fn() => new class implements Command {
                public function __invoke(Console $console): Console
                {
                    return $console->output(
                        Str::of('Hello ')->append(
                            $console->arguments()->get('name'),
                        ),
                    );
                }

                public function usage(): string
                {
                    return 'greet name';
                }
            },
        );
    }
};
```

You can now do `php bin/console greet John` to print `Hello John`.

??? info
    This is the same classes used in a small [CLI app](../app/cli.md). This allows you to easily migrate in case you app grows and you decide to use this framework.

??? tip
    The full definition of the function passed to the `command` method is:

    ```php
    use Innmind\DI\Container;
    use Innmind\OperatingSystem\OperatingSystem;
    use Innmind\Framework\Environment;
    use Innmind\CLI\Command;

    static fn(Container $container, OperatingSystem $os, Environment $env): Command;
    ```

    - `$container` is a service locator
    - `$os` you've seen it in previous section
    - `$env` contains the environment variables

You can add as many commands as uou wish by chaining calls to the `command` method.

## Composition

You can decorate all commands to execute some code on every command like this:

```php title="bin/console"
new class extends Cli {
    protected function configure(Application $app): Application
    {
        return $app
            ->mapCommand(
                static fn(Command $command) => new class($command) implements Command {
                    public function __construct(
                        private Command $inner,
                    ) {}

                    public function __invoke(Console $console): Console
                    {
                        // you can execute code before here
                        $console = ($this->inner)($console);
                        // you can execute code after here

                        return $console;
                    }

                    public function usage(): string
                    {
                        return $this->inner->usage();
                    }
                }
            )
            ->command(/* ... */)
            ->command(/* ... */)
            ->command(/* ... */);
        );
    }
};
```

For example you can use this approach to prevent commands to be run during deployments by checking if a file exists on the filesystem.
