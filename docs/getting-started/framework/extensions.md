# Extensions

## Built-in

This framework comes with these middlewares:

- `Innmind\Framework\Middleware\Optional` to load a middleware only if the class exist, as seen in the [profiler chapter](profiler.md)
- `Innmind\Framework\Middleware\LoadDotEnv` to load a `.env` file and inject the values in the `Innmind\Framework\Environment` object

## Others

You can find other packages exposing middlewares via the virutal package `innmind/framework-middlewares` on [Packagist](https://packagist.org/providers/innmind/framework-middlewares).
