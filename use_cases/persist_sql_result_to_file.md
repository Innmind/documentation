# Persist a SQL result to a file

```php
use Innmind\OperatingSystem\Factory;
use Innmind\Filesystem\File\{
    File,
    Content\Lines,
    Content\Line,
};
use Innmind\Url\{
    Url,
    Path,
};
use Innmind\Immutable\Str;
use Formal\AccessLayer\{
    Query\Select,
    Table\Name,
};

$os = Factory::build();

$sql = $os
    ->remote()
    ->sql(Url::of('mysql://127.0.0.1:3306/database_name'));

$_ = $os
    ->filesystem()
    ->mount(Path::of('some directory/'))
    ->add(File::named(
        'results.csv',
        Lines::of(
            $sql(Select::onDemand(Name::of('table_name')))
                ->map(
                    static fn($row) => $row
                        ->values()
                        ->map(static fn($value) => (string) $value->value()),
                )
                ->map(Str::of(',')->join(...))
                ->map(Line::of(...)),
        ),
    ));
```

Since the sql query is lazy (thanks to `::onDemand()`) you can persist a very long result without loading everything in memory.

> **Note** This example requires [`innmind/operating-system`](https://packagist.org/packages/innmind/operating-system).
