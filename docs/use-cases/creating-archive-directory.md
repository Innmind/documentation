# Creating an archive of a directory

```sh
composer require innmind/encoding:~1.0
```

```php
use Innmind\Filesystem\Name;
use Innmind\Url\Path;
use Innmind\Encoding\{
    Gzip,
    Tar,
};

$tar = $os
    ->filesystem()
    ->mount(Path::of('some/directory/'))
    ->get(Name::of('data'))
    ->map(Tar::encode($os->clock()))
    ->map(Gzip::compress())
    ->match(
        static fn($file) => $file,
        static fn() => throw new \RuntimeException('Data not found'),
    );
```

Here `$tar` represents a `.tar.gz` file containing all the files and directories from `some/directory/data/`.

!!! info
    The content of the `$tar` file is lazily computed meaning you can create an archive larger than the allowed PHP memory.
