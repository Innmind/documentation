# Operating System

This package allows you to deal with all interactions with the operating system in a declarative way.

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

## Advanced usage

Full documentation available [here](https://innmind.github.io/OperatingSystem/).
