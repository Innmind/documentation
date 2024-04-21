# Upload a local file via HTTP

```php
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

$boundary = Boundary::uuid();
$_ = $os
    ->filesystem()
    ->mount(Path::of('some directory/'))
    ->get(Name::of('your file.txt'))
    ->flatMap(
        static fn($file) => $os
            ->remote()
            ->http()(Request::of(
                Url::of('https://some-server.com/api/upload'),
                Method::post,
                ProtocolVersion::v11,
                Headers::of(ContentType::of('multipart', 'form-data', $boundary)),
                Multipart::boundary($boundary)
                    ->withFile('some[file]', $file)
                    ->asContent(),
            ))
            ->maybe(),
    )
    ->match(
        static fn() => null,
        static fn() => throw new \Exception('No file or failed to upload'),
    );
```
