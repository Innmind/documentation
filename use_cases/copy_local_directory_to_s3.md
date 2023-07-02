# Copy a local directory to S3

```php
use Innmind\OperatingSystem\Factory;
use Innmind\S3;
use Innmind\Url\{
    Url,
    Path,
};

$os = Factory::build();

$bucket = S3\Factory::of($os)->build(
    Url::of('https://acces_key:acces_secret@bucket-name.s3.region-name.scw.cloud/'),
    S3\Region::of('region-name'),
);
$s3 = S3\Filesystem\Adapter::of($bucket);

$directory = $os
    ->filesystem()
    ->mount(Path::of('some directory/'))
    ->root();
$s3->add($directory);
```

> **Note** This example requires [`innmind/operating-system`](https://packagist.org/packages/innmind/operating-system) and [`innmind/s3`](https://packagist.org/packages/innmind/s3).
