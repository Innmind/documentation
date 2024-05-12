# Monitoring

## Processes

You can access information on all processes currently running on the machine via:

```php
use Innmind\Server\Status\Server\Process;

$os
    ->status()
    ->processes()
    ->all()
    ->foreach(static function(Process $process): void {
        \printf(
            '%s is running %s',
            $process->user()->toString(),
            $process->command()->toString(),
        );
    });
```

On each process you have access to:

- its pid
- the user that started it
- the current cpu percentage
- the current amount of memory used
- when it started (may not always be available)
- the command

The cpu and memory usage is a snapshot of when you called `->all()`. If you want an updated value you need to refetch the process via:

```php
$updatedProcess = $os
    ->status()
    ->processes()
    ->get($process->pid());
```

??? info
    Since the process may have finished in the meantime `->get()` returns a `Maybe<Process>`.

## Disk

You can access all the mounted volumes via:

```php
use Innmind\Server\Status\Server\Disk\Volume;

$os
    ->status()
    ->disk()
    ->volumes()
    ->foreach(static function(Volume $volume): void {
        \printf(
            '%s uses %s',
            $volume->mountPoint()->toString(),
            $volume->used()->toString(),
        );
    });
```

On each volume you have access to its mount point and its usage. The values are a snapshot of when you called `->volumes()`, if you want an updated value you need to refetch the volumes.

## CPU

```php
$cpu = $os
    ->status()
    ->cpu();
```

On `$cpu` you have access to a snapshot of the percentage of cpu used by the user or the system. You also have access to the number of cores available, you can use this information to adapt your program if you want to start child processes.

## Memory

```php
$memory = $os
    ->status()
    ->memory();
```

On `$memory` you have access to a snapshot of the memory used, the swap used and the total memory available.

## Load average

```php
$load = $os
    ->status()
    ->loadAverage();
$load->lastMinute();
$load->lastFiveMinutes();
$load->lastFifteenMinutes();
```

You can use this load average to know if you can handle more work in your program or start throttling.

## Temporary directory

```php
$tmp = $os
    ->status()
    ->tmp();
```

`$tmp` is a `Innmind\Url\Path` that you can use to [mount a filesystem](filesystem.md) or use as a working directory when [launching processes](processes.md).
