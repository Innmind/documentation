# Creating an archive of a directory

```php
use Innmind\Filesystem\{
    Name,
    File\Content,
};
use Innmind\Url\Path;
use Innmind\Encoding\{
    Gzip,
    Tar,
};

$tar = $os
    ->filesystem()
    ->mount(Path::of('some/directory/'))
    ->unwrap()
    ->get(Name::of('data'))
    ->map(Tar::encode($os->clock()))
    ->map(Gzip::compress())
    ->match(
        static fn(Content $file) => $file,
        static fn() => throw new \RuntimeException('Data not found'),
    );
```

Here `$tar` represents a `.tar.gz` file containing all the files and directories from `some/directory/data/`.

!!! info
    The content of the `$tar` file is lazily computed meaning you can create an archive larger than the allowed PHP memory.
