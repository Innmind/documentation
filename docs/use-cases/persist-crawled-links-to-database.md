# Persist crawled links to a database

```sh
composer require innmind/html:~6.3
```

```php
use Innmind\Http\{
    Request,
    Method,
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

$read = Reader::default();
$sql = $os
    ->remote()
    ->sql(Url::of('mysql://127.0.0.1:3306/database_name'));

$_ = $os
    ->remote()
    ->http()(Request::of(
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
    ->map(static fn(A $a) => $a->href()->toString())
    ->foreach(static fn(string $href) => $sql(Insert::into(
        Name::of('table_name'),
        Row::of(['column_name' => $href]),
    )));
```
