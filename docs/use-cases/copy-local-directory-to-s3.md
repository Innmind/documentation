# Copy a local directory to S3

```sh
composer require innmind/s3:~4.1
```

```php
use Innmind\S3;
use Innmind\Url\{
    Url,
    Path,
};

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
