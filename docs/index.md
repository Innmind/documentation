---
hide:
    - navigation
    - toc
---

# Welcome to Innmind

Innmind bridges Object Oriented Programming and Functional Programming in a coherent ecosystem to bring high level abstraction to life.

This documentation will show you how to move from simple scripts all the way to distributed systems (and all the steps in-between) by using a single way to code.

If you've seen modern Java, C#, Rust, Swift and co you should find Innmind very familiar.

??? example "Sneak peek"
    The code below shows how the declarative nature of Innmind abstracts away the complexity.

    ```php
    $os
        ->filesystem()
        ->mount(Path::of('somewhere/data/'))
        ->unwrap()
        ->get(Name::of('avatars'))
        ->keep(Instance::of(Directory::class))
        ->map(
            static fn(Directory $directory) => $directory->add(File::named(
                'users.csv',
                Content::ofLines(
                    $orm
                        ->repository(User::class)
                        ->all()
                        ->map(static fn(User $user) => $user->toArray())
                        ->map(static fn(array $user) => \implode(',', $user))
                        ->map(Str::of(...))
                        ->map(Line::of(...)),
                ),
            )),
        )
        ->map(Tar::encode($os->clock()))
        ->map(Gzip::encode())
        ->match(
            static fn(File $tar) => Response::of(
                StatusCode::ok,
                ProtocolVersion::v11,
                null,
                $tar->content(),
            ),
            static fn() => Response::of(
                StatusCode::noContent,
                ProtocolVersion::v11,
            ),
        );
    ```

    This example sends an HTTP response of a `.tar.gz` containing all files contained in an `avatars` directory and with a CSV of all users stored in a database. All this is done with the guarantee that you won't run in "out of memory" errors, and other advantages you'll learn throughout this documentation.

By following the links at the bottom of each page you'll progressively learn your way through Innmind. While the [Philosophy](philosophy/index.md) chapter is an important part you can skip to the [Getting started](getting-started/index.md) one if you want to feel what it's like to code with Innmind.
