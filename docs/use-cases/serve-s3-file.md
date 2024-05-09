# Serve a S3 file via an HTTP server

```sh
composer require innmind/s3:~4.1
```

```php
use Innmind\Framework\{
    Application,
    Main\Http,
    Http\To,
};
use Innmind\S3;
use Innmind\Filesystem\{
    Adapter,
    Name,
};
use Innmind\Http\{
    ServerRequest,
    Response,
    Response\StatusCode,
    Headers,
    Header\ContentType,
};
use Innmind\Url\Url;

new class extends Http {
    protected function configure(Application $app): Application
    {
        return $app
            ->service('s3', static fn($_, $os) => S3\Filesystem\Adapter::of(
                S3\Factory::of($os)->build(
                    Url::of('https://acces_key:acces_secret@bucket-name.s3.region-name.scw.cloud/'),
                    S3\Region::of('region-name'),
                ),
            ))
            ->service('serve', static fn($get) => new class($get('s3')) {
                public function __construct(private Adapter $s3){}

                public function __invoke(ServerRequest $request): Response
                {
                    return $this
                        ->s3
                        ->get(Name::of('some file.txt'))
                        ->match(
                            static fn($file) => Response::of(
                                StatusCode::ok,
                                $request->protocolVersion(),
                                Headers::of(ContentType::of(
                                    $file->mediaType()->topLevel(),
                                    $file->mediaType()->subType(),
                                )),
                                $file->content(),
                            ),
                            static fn() => new Response(
                                StatusCode::notFound,
                                $request->protocolVersion(),
                            ),
                        );
                }
            })
            ->route('GET /', To::service('serve'));
    }
};
```

!!! tip
    Head to the [framework chapter](../getting-started/framework/index.md) to learn how to call this server.
