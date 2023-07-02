# Upload a local file via HTTP

```php
use Innmind\OperatingSystem\Factory;
use Innmind\Filesystem\Name;
use Innmind\Http\{
    Message\Request\Request,
    Message\Method,
    Content\Multipart,
    Header\ContentType,
    Header\ContentType\Boundary,
    Headers,
    ProtocolVersion,
};
use Innmind\Url\{
    Url,
    Path,
};

$os = Factory::build();

$boundary = Boundary::uuid();
$_ = $os
    ->filesystem()
    ->mount(Path::of('some directory/'))
    ->get(Name::of('your file.txt'))
    ->flatMap(
        static fn($file) => $os
            ->remote()
            ->http()(new Request(
                Url::of('https://some-server.com/api/upload'),
                Method::post,
                ProtocolVersion::v11,
                Headers::of(ContentType::of('multipart', 'form-data', $boundary)),
                Multipart::boundary($boundary)->withFile('some[file]', $file),
            ))
            ->maybe(),
    )
    ->match(
        static fn() => null,
        static fn() => throw new \Exception('No file or failed to upload'),
    );
```

> **Note** This example requires [`innmind/operating-system`](https://packagist.org/packages/innmind/operating-system).
