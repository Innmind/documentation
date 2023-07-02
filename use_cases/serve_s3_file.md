# Serve a S3 file via an HTTP server

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
    Message\ServerRequest,
    Message\Response\Response,
    Message\StatusCode,
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
                            static fn($file) => new Response(
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

> **Note** This example requires [`innmind/framework`](https://packagist.org/packages/innmind/framework) and [`innmind/s3`](https://packagist.org/packages/innmind/s3).
