# HTTP

## Usage

The first step is to define the entrypoint:

```php title="public/index.php"
<?php
declare(strict_types = 1);

require 'path/to/composer/autoload.php';

use Innmind\Framework\{
    Main\Http,
    Application,
};

new class extends Http {
    protected function configure(Application $app): Application
    {
        return $app;
    }
};
```

You can expose this server via `cd public/ && php -S localhost:8080`. If you run `curl http://localhost:8080/` it will return a `404` response which is the default behaviour when you didn't specify any route.

You can define a route like this:

```php title="public/index.php"
use Innmind\Framework\Http\Route;
use Innmind\Http\{
    ServerRequest,
    Response,
};
use Innmind\Filesystem\File\Content;
use Innmind\Immutable\Attempt;

enum Services implements Service
{
    case hello;
}

new class extends Http {
    protected function configure(Application $app): Application
    {
        return $app
            ->service(
                Services::hello,
                static fn() => static fn(ServerRequest $request) => Attempt::result(
                    Response::of(
                        Response\StatusCode::ok,
                        $request->protocolVersion(),
                        null,
                        Content::ofString('Hello world'),
                    ),
                ),
            )
            ->route(Route::get(
                '/',
                Services::hello,
            );
    }
};
```

Now `curl http://localhost:8080/` will return a `200` response with the content `Hello world`.

You can specify placeholders in your routes like this:

```php title="public/index.php" hl_lines="7 12 17"
new class extends Http {
    protected function configure(Application $app): Application
    {
        return $app
            ->service(
                Services::hello,
                static fn() => static fn(ServerRequest $request, string $name) => Attempt::result(
                    Response::of(
                        Response\StatusCode::ok,
                        $request->protocolVersion(),
                        null,
                        Content::ofString("Hello $name"),
                    ),
                ),
            )
            ->route(Route::get(
                '/greet/{name}',
                Services::hello,
            );
    }
};
```

`curl http://localhost:8080/greet/Jane` will return `Hello Jane`.

!!! info ""
    The route template is defined by the [RFC6570](https://tools.ietf.org/html/rfc6570). You can learn more about its implementation in this [package](https://github.com/Innmind/UrlTemplate).

??? tip
    The full definition of the function passed to the `route` method is:

    ```php
    use Innmind\Router\{
        Component,
        Pipe,
    };
    use Innmind\DI\Container;

    static fn(
        Pipe $pipe
        Container $container,
    ): Component;
    ```

    - `$pipe` is a factory to help build routes
    - `$container` is a service locator

## Composition

You can decorate all routes to execute some code on every route like this:

```php title="public/index.php"
new class extends Http {
    protected function configure(Application $app): Application
    {
        return $app
            ->mapRoute(
                static fn(Component $route) => Component::of(static function(
                    ServerRequest $request,
                    mixed $input,
                ) {
                    // you can execute code before here

                    return Attempt::result($input);
                })
                    ->pipe($route)
                    ->pipe(Component::of(static function($request, $response) {
                        // you can execute code after here

                        return Attempt::result($response);
                    })),
            )
            ->route(/* ... */)
            ->route(/* ... */)
            ->route(/* ... */);
        );
    }
};
```

For example you can use this approach to prevent routes to be run during deployments by checking if a file exists on the filesystem.

## Webserver

### Apache, Nginx, Caddy, etc...

In the example above we expose the program via a `public/` folder. You can expose this folder with any HTTP server you're familiar with.

You'll need to enable url rewriting so all paths requested are redirected to the `index.php` file.

### Built-in

Instead of using the `Innmind\Framework\Main\Http` entrypoint you can use `Innmind\Framework\Main\Async\Http`. Now the PHP file is a CLI program that will open the port `8080` by default on your machine.

You can send it `curl` requests just as before. The difference is that your code now runs asynchronously (1).
{.annotate}

1. As long as you use the [Operating System abstraction](../operating-system/index.md).

!!! warning ""
    This execution mode however is limited. For example it doesn't support multipart requests.

    You should use this as an experiment to see how your code behave asynchronously.
