# Middlewares

So far you've configured each kind of app directly in its entrypoint. This is fine for small apps that you don't unit test. But as your program grows you'll need to better structure it and test it.

The way to organise the framework configuration is through _middlewares_. And it looks like that:

```php
use Innmind\Framework\{
    Application,
    Middleware,
};

final class MyMiddleware implements Middleware
{
    public function __invoke(Application $app): Application
    {
        return $app
            ->command(/* as seen previously */)
            ->route(/* as seen previously */);
    }
}
```

In this method you can configure the `Application` the same way you would do in the entrypoint. And since the configuration api is the same no matter the entry point chosen (HTTP or CLI) you can declare both CLI commands and HTTP routes inside the same middleware.

And to use it:

```php
use Innmind\Framework\{
    Main\Http,
    Application,
};

new class extends Http {
    protected function configure(Application $app): Application
    {
        return $app->map(new MyMiddleware);
    }
};
```

??? info
    The notation `$app->map($middleware)` is just an invertion of who calls who for better chaining methods. If you look at the implementation it does `$middleware($app)`.

Since the middleware is a plain old PHP object, you can also add parameters to it.

Let's say your program is a website that is accessible both in french and english. Instead of adding a parameter in every route and pass it around in every layer of your program you could do:

=== "Entrypoint"
    ```php
    use Innmind\Framework\{
        Main\Http,
        Application,
    };

    new class extends Http {
        protected function configure(Application $app): Application
        {
            return $app
                ->map(new MyMiddleware('fr'))
                ->map(new MyMiddleware('en'));
        }
    };
    ```

=== "Middleware"
    ```php
    final class MyMiddleware implements Middleware
    {
        private string $language;

        public function __construct(string $language)
        {
            $this->language = $language;
        }

        public function __invoke(Application $app): Application
        {
            return $app
                ->route("GET /{$this->language}", /* index handler */)
                ->route("GET /{$this->language}/route1", /* handler */)
                ->route("GET /{$this->language}/route2", /* handler */)
                ->route("GET /{$this->language}/route/etc", /* handler */);
        }
    }
    ```

??? tip
    And since you have access to the language at the configuration time you could even use different databases.

    === "Middleware"
        ```php
        final class MyMiddleware implements Middleware
        {
            private string $language;

            public function __construct(string $language)
            {
                $this->language = $language;
            }

            public function __invoke(Application $app): Application
            {
                return $app
                    ->service(
                        Services::database($this->language),
                        fn($_, $os) => $os
                            ->remote()
                            ->sql(Url::of(match ($this->language) {
                                'en' => 'mysql://127.0.0.1:3306/website_en',
                                'fr' => 'mysql://127.0.0.1:3306/website_fr',
                            })),
                    )
                    ->route(
                        "GET /{$this->language}",
                        function(
                            $request,
                            $variables,
                            Container $get,
                        ) {
                            $sql = $get(Services::database($this->language));
                            $someData = $sql(/* some Query */);

                            return Response::of(/* build response with $someData */);
                        }
                    );
            }
        }
        ```

    === "`Services`"
        ```php
        enum Services
        {
            case databaseEn;
            case databaseFr;

            public static function database(string $language): self
            {
                return match ($language) {
                    'en' => self::databaseEn,
                    'fr' => self::databaseFr,
                };
            }
        }
        ```
