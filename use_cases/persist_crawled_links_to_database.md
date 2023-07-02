# Persist crawled links to a database

```php
use Innmind\OperatingSystem\Factory;
use Innmind\Http\{
    Message\Request\Request,
    Message\Method,
    ProtocolVersion,
};
use Innmind\Html\{
    Reader\Reader,
    Visitor\Elements,
    Element\A,
};
use Innmind\Url\Url;
use Innmind\Immutable\Predicate\Instance;
use Formal\AccessLayer\{
    Query\Insert,
    Table\Name,
    Row,
};

$os = Factory::build();
$reader = Reader::default();
$sql = $os
    ->remote()
    ->sql(Url::of('mysql://127.0.0.1:3306/database_name'));

$_ = $os
    ->remote()
    ->http()(new Request(
        Url::of('https://some-server.com/page.html')
        Method::get,
        ProtocolVersion::v11,
    ))
    ->maybe()
    ->map(static fn($success) => $success->response()->body())
    ->flatMap($read)
    ->toSequence()
    ->toSet()
    ->flatMap(Elements::of('a'))
    ->keep(Instance::of(A::class))
    ->map(static fn($a) => $a->href()->toString())
    ->foreach(static fn($href) => $sql(Insert::into(
        Name::of('table_name'),
        Row::of(['column_name' => $href]),
    )));
```

> **Note** This example requires [`innmind/operating-system`](https://packagist.org/packages/innmind/operating-system) and [`innmind/html`](https://packagist.org/packages/innmind/html).
