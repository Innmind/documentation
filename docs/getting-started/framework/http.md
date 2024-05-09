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

You can expose this server via `cd public/ && php -S localhost:8080`. If you run `curl http://localhost:8080/` it will return a `404` response which is the default behaviour when you dn'ont specify any route.

You can define a route like this:

```php title="public/index.php"
use Innmind\Http\{
    ServerRequest,
    Response,
};
use Innmind\Filesystem\File\Content;

new class extends Http {
    protected function configure(Application $app): Application
    {
        return $app->route(
            'GET /',
            static fn(ServerRequest $request) => Response::of(
                Response\StatusCode::ok,
                $request->protocolVersion(),
                null,
                Content::ofString('Hello world'),
            ),
        );
    }
};
```

Now `curl http://localhost:8080/` will return a `200` response with the content `Hello world`.

You can specify placeholder in your routes like this:

```php title="public/index.php" hl_lines="1 7 10 15"
use Innmind\Router\Route\Variables;

new class extends Http {
    protected function configure(Application $app): Application
    {
        return $app->route(
            'GET /greet/{name}',
            static fn(
                ServerRequest $request,
                Variables $variables
            ) => Response::of(
                Response\StatusCode::ok,
                $request->protocolVersion(),
                null,
                Content::ofString('Hello '.$variables->get('name')),
            ),
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
    use Innmind\Http\{
        ServerRequest,
        Response,
    };
    use Innmind\Router\Route\Variables;
    use Innmind\DI\Container;
    use Innmind\OperatingSystem\OperatingSystem;
    use Innmind\Framework\Environment;

    static fn(
        ServerRequest $request
        Variable $variables,
        Container $container,
        OperatingSystem $os,
        Environment $env
    ): Response;
    ```

    - `$request` is the parsed request sent by a user
    - `$variables` gathers all the values described by the route template
    - `$container` is a service locator
    - `$os` you've seen it in the previous chapter
    - `$env` contains the environment variables

## Composition

You can decorate all routes to execute some code on every route like this:

```php title="public/index.php"
use Innmind\Framework\Http\RequestHandler;

new class extends Http {
    protected function configure(Application $app): Application
    {
        return $app
            ->mapRequestHandler(
                static fn(RequestHandle $route) => new class($route) implements RequestHandler {
                    public function __construct(
                        private RequestHandler $inner,
                    ) {}

                    public function __invoke(ServerRequest $request): Response
                    {
                        // you can execute code before here
                        $response = ($this->inner)($request);
                        // you can execute code after here

                        return $response;
                    }
                }
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
