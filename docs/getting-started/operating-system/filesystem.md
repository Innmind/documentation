# Filesystem

## Access

### Concepts

Files and directories are accessed via `Adapter`s that are _mounted_ through the `$os`.

A `Directory` is represented by a `Name` and an immutable [`Sequence`](../handling-data/sequence.md) of files and directories.

A `File` is represented by a `Name`, a `MediaType` and a `Content`.

A `Content` is either viewed as an immutable `Sequence` of `Line`s or of chunks. This allows to handle human readable files line by line and alter them like any other `Sequence`. And to handle binary files as a `Sequence` of `Str` chunks.

!!! tip ""
    Since a `Content` can be described via a `Sequence`, anytime you see a `Sequence` you have an opportunity to convert it into a `Content`.

??? note
    Even though a `Content` is immutable it loads the content from the filesystem upon use. This means that if a process deletes the file between the time you retrieved the `File` and the time you work with its `Content` your program will fail.

    So be careful of the concurrency in your program!

Via these immutable structures you can describe your filesystem structures in a [_pure_ code](../../philosophy/oop-fp.md#purity) and apply it later on in your program.

### Accessing files

```php
use Innmind\Filesystem\{
    File,
    Name,
};
use Innmind\Url\Path;
use Innmind\Immutable\Predicate\Instance;

$os
    ->filesystem()
    ->mount(Path::of('some directory/')) #(1)
    ->unwrap()
    ->get(Name::of('some-file.txt'))
    ->keep(Instance::of(File::class))
    ->match(
        static fn(File $file) => doStuff($file->content()->toString()),
        static fn() => fileDoesntExist(),
    );
```

1. The path must end with a `/`.

This reads the content of the file at `some directory/some-file.txt`. But if your file is located under a `sub folder` you would do:

```php
use Innmind\Filesystem\Directory;

$os
    ->filesystem()
    ->mount(Path::of('some directory/'))
    ->unwrap()
    ->get(Name::of('sub folder'))
    ->keep(Instance::of(Directory::class))
    ->flatMap(static fn(Directory $directory) => $directory->get(
        Name::of('some-file.txt'),
    ))
    ->match(
        static fn(File $file) => doStuff($file->content()->toString()),
        static fn() => fileDoesntExist(),
    );
```

??? note
    You can use any level of directory nesting, as long as it's supported by your machine's filesystem.

If you want to access all the files at the root of the adapter you can do:

```php
$files = $os
    ->filesystem()
    ->mount(Path::of('some directory/'))
    ->unwrap()
    ->root()
    ->all()
    ->keep(Instance::of(File::class));
$files; // instance of Sequence<File>
```

### Persisting files

To add a file at the root of the adapter you can do:

```php
$os
    ->filesystem()
    ->mount(Path::of('some directory/'))
    ->unwrap()
    ->add(File::named(
        'some name',
        Content::ofString('the file content'),
    ))
    ->unwrap();
```

??? note
    If the write fails for any reason it will throw an exception. But since the files and directories are immutable you can retry them safely.

You can construct the content of a file either via:

- `Content::ofString()` where the string is the whole file, but beware of memory allocation
- `Content::ofLines()` that expect a `Sequence<Content\Line>`, this automatically handles the lines feed character
- `Content::ofChunks()` that expect a `Sequence<Innmind\Immutable\Str>`
- `Content::none()` to create an empty file

If you want to create a file inside a directory you can do:

```php
$os
    ->filesystem()
    ->mount(Path::of('some directory/'))
    ->unwrap()
    ->add(
        Directory::named('sub folder')->add(
            File::named(
                'some name',
                Content::ofString('the file content'),
            ),
        ),
    )
    ->unwrap();
```

!!! note
    If the `sub folder/` already exist it will add your file, any other file inside it won't be affected.

### Removing files

If you want to remove a file/directory at the root of the adapter you can do:

```php
$os
    ->filesystem()
    ->mount(Path::of('some directory/'))
    ->unwrap()
    ->remove(Name::of('some file'))
    ->unwrap();
```

!!! note
    If you delete a directory it will automatically remove all files inside it!

If the file/directory doesn't exist it will do nothing, since the end result is the same (the absence of the file/directory).

To remove a file inside a directory you _add a new version of the directory_:

```php
$os
    ->filesystem()
    ->mount(Path::of('some directory/'))
    ->unwrap()
    ->add(
        Directory::named('sub folder')->remove(
            Name::of('some file'),
        ),
    )
    ->unwrap();
```

??? info
    Alternatively you can also retrieve the directory, remove the file and re-add the new directory object. However this will be less performant.

### Modifying file content

Let's say you have a log file that you want to duplicate but containing only the errors you can do:

```php
$adapter = $os->filesystem()->mount(Path::of('logs/'))->unwrap();
$adapter
    ->get(Name::of('prod.log'))
    ->keep(Instance::of(File::class))
    ->map(
        static fn(File $file) => $file
            ->rename(Name::of('errors.log'))
            ->withContent(
                $file
                    ->content()
                    ->filter(
                        static fn(Line $line) => $line
                            ->str()
                            ->contains('app.ERROR'),
                    ),
            ),
    )
    ->match(
        static fn(File $file) => $adapter->add($file)->unwrap(),
        static fn() => null, // prod.log doesn't exist
    );
```

You can use `Content::map()` to change each line of a file. `Content::flatMap()` allows to replace one line by multiple ones, you can use this to merge multiple files together.

??? warning
    You can't write to the file you're trying to modify. This means you can't do this:

    ```php
    $adapter
        ->get(Name::of('some file'))
        ->keep(Instance::of(File::class))
        ->map(static fn(File $file) => $file->withContent(
            $file
                ->content()
                ->map(static fn(Line $line) => Line::of(Str::of('some value'))),
        ))
        ->match(
            static fn(File $file) => $adapter->add($file)->unwrap(),
            static fn() => null,
        );
    ```

    You need to write the modified version to a temporary file, read this file to write it to the original file. But a [feature is planned](https://github.com/Innmind/Filesystem/issues/3) to allow to do in place modification.

## Watching for changes

Let's say you have a directory and you want to execute some code every time someone adds a file to it. You can do this:

```php
use Innmind\FileWatch\Continuation;
use Innmind\Url\Path;

$watch = $os->filesystem()->watch(Path::of('some directory/'));
$result = $watch(
    0,
    static function(int $count, Continuation $continuation) {
        if ($count === 42) {
            return $continuation->stop($count);
        }

        doStuff();

        return $continuation->continue($count + 1);
    },
);
```

Here you'll react to `42` modifications of the directory `some directory/` and then assign `42` to `$result`. In essence this acts as a _reduce_ operation that could be infinite.

!!! note ""
    `0` and `int $count` are a carried value between each call of the function. Here it's an `int` but you can use any type you want.

??? warning
    You should **not** use this method in production as it executes a `stat` command every second.

## Loading PHP files

Let's say you have a script that may be configured by an external PHP file. The config file may or may not exist and your script need to adapt to that.

```php title="config.php"
return [
    'some' => 'value',
    'key' => 'foo',
];
```

In your script you can do:

```php
$config = $os
    ->filesystem()
    ->require(Path::of('config.php'))
    ->match(
        static fn(array $config) => $config,
        static fn() => [
            'some' => 'default value',
            'key' => 'default value',
        ],
    );
```

If the file exist then the return value from `config.php` is passed to the first callable passed to `match` otherwise the second callable is called.

Here the returned value is an `array` but it can be any value.
