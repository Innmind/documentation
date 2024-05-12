# Production

## Choose the right storage

Now that you know how to use the main features of this ORM, it's time to really persist the data.

As said in the introduction you have 3 options:

- SQL
- Elasticsearch
- Filesystem

If you need a reliable storage you should use SQL as it's battle proven.

If you're trying to build a proof of concept then it's probable not necessary to use any third party storage and go with the filesystem.

If you need efficiency when searching for your aggregates then you should go with Elasticsearch.

!!! success ""
    The 3 storages are tested against the same properties. This means that the behaviour between all of them will be the same. So you can switch between them.

## SQL

### Setup

```php
use Formal\ORM\Manager;
use Innmind\Url\Url;

$connection = $os
    ->remote()
    ->sql(Url::of('mysql://user:password@127.0.0.1:3306/database'));
$orm = Manager::sql($connection);
```

The rest of your code doesn't have to change.

### Creating the tables

In order to persist your data you first need to create the tables where they'll be stored.

```php
$aggregates = Aggregates::of(Types::default()); #(1)
$show = ShowCreateTable::of($aggregates);

$_ = $show(User::class)->foreach($connection); #(2)
```

1. Don't forget to also declare your own types here.
2. You don't need to specify the entities here, only the aggregates class.

This code automatically execute the queries to create the tables. You could instead print them (1) and store them in a database migration tool.
{.annotate}

1. `#!php $_ = $show(User::class)->foreach(var_dump(...));`

??? warning
    Unfortunately Innmind doesn't have a migration package yet. For now you could use [`doctrine/migrations`](https://packagist.org/packages/doctrine/migrations).

## Elasticsearch

You first need to run an Elasticsearch instance, head to their [documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/getting-started.html) to learn how to start one.

Then change the adapter of the manager:

```php
use Formal\ORM\Adapter\Elasticsearch;
use Innmind\Url\Url;

$orm = Manager::of(
    Elasticsearch::of(
        $os->remote()->http(),
        Url::of('http://localhost:9200/'), #(1)
    ),
);
```

1. If you use a local instance you can omit this parameter.

??? tip
    If you want to run tests against a real instance of Elasticsearch you should decorate the HTTP client like this:

    ```php
    use Formal\ORM\Adapter\Elasticsearch\Refresh;

    Elasticsearch::of(Refresh::of(
        $os->remote()->http(),
    ));
    ```

    This decorator makes sure each modification to the index are applied instantaneously. **DO NOT** use this decorator in production as it will overload your instance.

Finally you need to create the index:

```php
use Formal\ORM\{
    Definition\Aggregates,
    Definition\Types,
    Adapter\Elasticsearch\CreateIndex,
};
use Innmind\Url\Url;

$aggregates = Aggregates::of(Types::default()); #(1)
$createIndex = CreateIndex::of(
    $os->remote()->http(),
    $aggregates,
    Url::of('http://localhost:9200/'),
);

$_ = $createIndex(User::class)->match(
    static fn() => null,
    static fn() => throw new \RuntimeException('Failed to create index'),
);
```

1. Don't forget to also declare your own types here.

??? warning
    Unlike other storages Elasticsearch doesn't support transactions.

    Elasticsearch also doesn't allow to list more than 10k aggregates, this means that if you store more than that you won't be able to list them all in a single `Sequence`. You'll need to use explicit search queries to find them all back.

## Filesystem

### Local

This is the best storage when starting to develop a new program as there's no schema to update. This allows for rapid prototyping.

```php
use Innmind\Url\Path;

$orm = Manager::filesystem(
    $os
        ->filesystem()
        ->mount(Path::of('path/where/to/store/data')),
);
```

And... that's it.

### S3

You should this storage for small programs without much concurrency that you need to synchronise for multiple clients. A good example is a CLI program that you want to work across multiple machines.

First you need to require the S3 package:

```sh
composer require innmind/s3:~4.1
```

Then configure the ORM:

```php
use Innmind\S3\{
    Factory,
    Region,
    Filesystem,
};
use Innmind\Url\Url;

$bucket = Factory::of($os)->build(
    Url::of('https://acces_key:acces_secret@bucket-name.s3.region-name.scw.cloud/'),
    Region::of('region-name'),
);
$orm = Manager::filesystem(
    Filesystem\Adapter::of($bucket),
);
```
