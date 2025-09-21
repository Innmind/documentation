# CLI

This package allows you to build scripts in a more structured way.

## Usage

```php title="cli.php"
<?php
declare(strict_types = 1);

require 'path/to/composer/autoload.php';

use Innmind\CLI\{
    Main,
    Environment,
};
use Innmind\OperatingSystem\OperatingSystem;
use Innmind\Immutable\Attempt;

new class extends Main {
    protected function main(Environment $env, OperatingSystem $os): Attempt
    {
        return $env->output(Str::of("Hello world\n"));
    }
};
```

If you run `php cli.php` in your terminal it will print `Hello world`.

You should already be familiar with the `$os` variable by now, if not go the [dedicated chapter](../operating-system/index.md).

The `$env` variable is the abstraction to deal with everything inputed in your script and every output that comes out. It behaves like an immutable object, meaning you **must** always use the new instance returned by its methods.

To change the returned exit code you can do `$env->exit(1)`.

If you only have one action in your script you can do everything in the `main` method. But if you want to expose multiple commands you can do:

```php title="cli.php"
use Innmind\CLI\{
    Commands,
    Console,
    Command,
    Command\Usage,
};
use Innmind\Immutable\Attempt;

new class extends Main {
    protected function main(Environment $env, OperatingSystem $os): Environment
    {
        $commands = Commands::of(
            new class implements Command {
                public function __invoke(Console $console): Attempt
                {
                    return $console->output(
                        Str::of('Hello ')->append(
                            $console->arguments()->get('name'),
                        ),
                    );
                }

                public function usage(): Usage
                {
                    return Usage::parse('greet name');
                }
            },
            new class implements Command {
                public function __invoke(Console $console): Attempt
                {
                    return $console->output(
                        Str::of($console->arguments()->get('name'))
                            ->toUpper()
                            ->prepend('Hello '),
                    );
                }

                public function usage(): Usage
                {
                    return Usage::parse('shout name');
                }
            },
        );

        return $commands($env);
    }
};
```

If you run `php cli.php greet Jane` it will output `Hello Jane` and if you run `php cli.php shout John` it will output `Hello JOHN`.

??? info
    For simplicity this example use anonymous classes but you can use any class as long as it implements `Command`.

## Advanced usage

Full documentation available [here](http://innmind.org/CLI/).
