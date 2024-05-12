# Operating System

This package allows you to deal with all interactions with the operating system in a declarative way.

## Installation

```sh
composer require innmind/operating-system:~5.0
```

## Usage

```php
use Innmind\OperatingSystem\{
    Factory,
    OperatingSystem,
};

$os = Factory::build();
$os instanceof OperatingSystem; // returns true
```

You'll see in the following chapters all the ways you can use this object.

!!! info ""
    From this point on everytime you see the variable `$os` it refers to this object.

??? warning
    This package is not compatible with Windows.

## Configuration

By default the configuration of the `$os` should be fine for all use cases, but you can change some aspects via the `Config` object:

```php
use Innmind\OperatingSystem\Config;

$os = Factory::build(
    Config::of()
        ->disableSSLVerification()
        ->caseInsensitiveFilesystem(),
);
```

Here we tell the abstraction that we work on a case insensitive filesystem and that the HTTP client should not check the SSL certificates (1). But this class allows more configuration, you should take a look at all its methods.
{.annotate}

1. You should do this only when working locally. Do **NOT** do this in production.
