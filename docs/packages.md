---
hide:
    - navigation
---

# Other Packages

## Access Control List

Immutable object version to define unix permissions.

```sh
composer require innmind/acl:~3.1
```

```php
use Innmind\ACL\{
    ACL,
    User,
    Group,
    Mode,
};

$acl = ACL::of('r---w---x user:group');

$acl->allows(User::of('foo'), Group::of('bar'), Mode::read); // false
$acl->allows(User::of('foo'), Group::of('bar'), Mode::execute); // true
```

[Repository](https://github.com/Innmind/ACL)

## Coding standard

Specifies the code style used throughout Innmind.

```sh
composer require --dev innmind/coding-standard:~2.0
```

```php title=".php-cs-fixer.dist.php"
<?php

return \Innmind\CodingStandard\CodingStandard::config(['src', 'proofs']);
```

```sh
vendor/bin/php-cs-fixer fix
```

[Repository](https://github.com/Innmind/coding-standard)

## Colour

Immutables objects to specify colours and switch between the notations (RGBA, HSL and CMYK).

```sh
composer install innmind/colour:~4.2
```

```php
use Innmind\Colour\Colour;

$rgba = Colour::of('#3399ff');
$hsla = Colour::of('hsl(210, 100%, 60%)');
$cmyka = Colour::of('device-cmyk(80%, 40%, 0%, 0%)');
$rgba = Colour::blue->toRGBA();
```

[Repository](https://github.com/Innmind/Colour)

## Cron

Immutable objects to define cron jobs and install them on a machine (local or remote).

```sh
composer require innmind/cron:~3.2
```

```php
use Innmind\Cron\{
    Crontab,
    Job,
};
use Innmind\Server\Control\Server\Command;

$install = Crontab::forUser(
    'admin',
    new Job(
        Job\Schedule::everyDayAt(10, 30),
        Command::foreground('say hello'),
    ),
);
$install($os->control());
```

[Repository](https://github.com/Innmind/Cron)

## Encoding

Allows to `tar` [directories](getting-started/operating-system/filesystem.md) and `gzip` [files](getting-started/operating-system/filesystem.md) in a memory safe way.

```sh
composer require innmind/encoding:~1.0
```

```php
use Innmind\Filesystem\{
    File,
    Name,
};
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
        static fn(File $file) => $file,
        static fn() => null,
    );
```

[Repository](https://github.com/Innmind/encoding)

## Hash

Allows to compute the hash of [files](getting-started/operating-system/filesystem.md) in a memory safe way.

```sh
composer require innmind/hash:~1.5
```

```php
use Innmind\Filesystem\Name;
use Innmind\Url\Path;
use Innmind\Hash\{
    Hash,
    Value,
};
use Innmind\Immutable\Set;

$hash = $os
    ->filesystem()
    ->mount(Path::of('some-folder/'))
    ->get(Name::of('some-file'))
    ->map(Hash::sha512->ofFile(...))
    ->match(
        static fn(Value $hash): string => $hash->hex(),
        static fn() => null,
    );
```

[Repository](https://github.com/Innmind/hash)

## Html

Allows to parse HTML files to immutable objects (built on top of [XML](#xml)).

```sh
composer require innmind/html:~6.3
```

```php
use Innmind\Html\Reader\Reader;
use Innmind\HttpTransport\Success;
use Innmind\Http\{
    Request,
    Method,
    ProtocolVersion,
};
use Innmind\Url\Url;
use Innmind\Xml\Node;
use Innmind\Immutable\Maybe;

$read = Reader::default();

$html = $os
    ->remote()
    ->http()(Request::of(
        Url::of('https://github.com/'),
        Method::get,
        ProtocolVersion::v11,
    ))
    ->maybe()
    ->map(static fn(Success $success) => $success->response()->body())
    ->flatMap($read);
$html; // instance of Maybe<Node>
```

[Repository](https://github.com/Innmind/Html)

## HTTP Authentication

Simple structures to define the ways to extract the identity from a [`ServerRequest`](getting-started/app/http.md).

[Repository](https://github.com/Innmind/HttpAuthentication)

## HTTP Session

Object approach to handle HTTP sessions without a global state.

[Repository](https://github.com/Innmind/HttpSession)

## Json

Type safe functions to encode/decode JSON to prevent unseen errors.

```sh
composer require innmind/json:~1.4
```

```php
use Innmind\Json\Json;

Json::encode(['foo' => 'bar']); // {"foo":"bar"}
Json::decode('{"foo":"bar"}'); // ['foo' => 'bar']
Json::decode('{]'); // will throw an exception (instead of returning false)
```

[Repository](https://github.com/Innmind/Json)

## Log reader

Allows to read Apache access and Monolog logs into immutable objects in a memory safe way.

```sh
composer require innmind/log-reader:~5.3
```

```php
use Innmind\LogReader\{
    Reader,
    LineParser\Monolog,
    Log,
};
use Innmind\Filesystem\{
    File,
    Name,
};
use Innmind\Url\Path;
use Innmind\Immutable\Predicate\Instance;
use Psr\Log\LogLevel;

$read = Reader::of(
    Monolog::of($os->clock()),
);
$os
    ->filesystem()
    ->mount(Path::of('var/logs/'))
    ->get(Name::of('prod.log'))
    ->keep(Instance::of(File::class))
    ->map(static fn($file) => $file->content())
    ->toSequence()
    ->flatMap($read)
    ->filter(
        static fn(Log $log) => $log
            ->attribute('level')
            ->filter(static fn($level) => $level->value() === LogLevel::CRITICAL)
            ->match(
                static fn() => true,
                static fn() => false,
            ),
    )
    ->foreach(
        static fn($log) => $log
            ->attribute('message')
            ->match(
                static fn($attribute) => print($attribute->value()),
                static fn() => print('No message found'),
            ),
    );
```

[Repository](https://github.com/Innmind/LogReader)

## RabbitMQ management

Object API on top of the `rabbitmqadmin` CLI command.

[Repository](https://github.com/Innmind/RabbitMQManagement)

## Robots.txt

Allows to parse `robots.txt` files.

```sh
composer require innmind/robots-txt:~6.2
```

```php
use Innmind\RobotsTxt\{
    Parser,
    RobotsTxt,
};
use Innmind\Url\Url;

$parse = Parser::of(
    $os->remote()->http(),
    'My user agent',
);
$robots = $parse(Url::of('https://github.com/robots.txt'))->match(
    static fn(RobotsTxt $robots) => $robots,
    static fn() => throw new \RuntimeException('robots.txt not found'),
);
$robots->disallows('My user agent', Url::of('/humans.txt')); // false
$robots->disallows('My user agent', Url::of('/any/other/url')); // true
```

[Repository](https://github.com/Innmind/Robots.txt)

## SSH key provider

Allows to fetch a user ssh keys from different sources.

```sh
composer require innmind/ssh-key-provider:~3.2
```

```php
use Innmind\SshKeyProvider\{
    Cache,
    Merge,
    Local,
    Github,
    PublicKey,
};
use Innmind\Url\Path;

$provide = Cache::of(
    Merge::of(
        Local::of(
            $os->filesystem()->mount(Path::of($_SERVER['USER'].'/.ssh/')),
        ),
        Github::of(
            $os->remote()->http(),
            'GithubUsername',
        ),
    ),
);

$provide()->foreach(static fn(PublicKey $key) => print($key->toString()));
```

[Repository](https://github.com/Innmind/SshKeyProvider)

## URL resolver

Allows to resolve a target url from a base one. This is useful for crawlers.

```sh
composer require innmind/url-resolver:~5.1
```

```php
use Innmind\UrlResolver\UrlResolver;
use Innmind\Url\Url;

$resolve = UrlResolver::of('http', 'https');

$url = $resolve(
    Url::of('http://example.com/foo/'),
    Url::of('./bar/baz?query=string#fragment'),
);
// $url resolves to http://example.com/foo/bar/baz?query=string#fragment
```

[Repository](https://github.com/Innmind/url-resolver)

## Validation

This is a monadic approach to data validation.

```sh
composer require innmind/validation:~1.4
```

```php
use Innmind\Validation\{
    Shape,
    Is,
    Each,
    Failure,
};
use Innmind\Immutable\Sequence;

$valid = [
    'id' => 42,
    'username' => 'jdoe',
    'addresses' => [
        'address 1',
        'address 2',
    ],
    'submit' => true,
];
$invalid = [
    'id' => '42',
    'addresses' => [
        'address 1',
        null,
    ],
    'submit' => true,
];

$validate = Shape::of('id', Is::int())
    ->with('username', Is::string())
    ->with(
        'addresses',
        Is::list(
            Is::string()->map(
                static fn(string $address) => new YourModel($address),
            )
        )
    );
$result = $validate($valid)->match(
    static fn(array $value) => $value,
    static fn() => throw new \RuntimeException('invalid data'),
);
// Here $result looks like:
// [
//      'id' => 42
//      'username' => 'jdoe',
//      'addresses' [
//          new YourModel('address 1'),
//          new YourModel('address 2'),
//      ],
//      (1)
// ]
$errors = $validate($invalid)->match(
    static fn() => null,
    static fn(Sequence $failures) => $failures
        ->map(static fn(Failure $failure) => [
            $failure->path()->toString(),
            $failure->message(),
        ])
        ->toList(),
);
// Here $errors looks like:
// [
//      ['id', 'Value is not of type int'],
//      ['$', 'The key username is missing'],
//      ['addresses', 'Value is not of type string']
// ]
```

1. See how the `submit` key disappeared.

[Repository](https://github.com/Innmind/validation)

## XML

Allows to parse XML files to immutable objects.

```sh
composer require innmind/xml:~7.5
```

```php
use Innmind\Xml\{
    Reader\Reader,
    Node,
};
use Innmind\Filesystem\File\Content;
use Innmind\Immutable\Maybe;

$read = Reader::of();

$tree = $read(
    Content::ofString('<root><foo some="attribute"/></root>')
); // Maybe<Node>
```

[Repository](https://github.com/Innmind/XML)
