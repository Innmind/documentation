# Properties

Properties are [proofs](proofs.md) extracted as classes so that they can be run in a different context. More specifically they verify the behaviour of objects.

The main goal of these properties is to make sure multiple implementations of a given system all behave the same way.

The most prominent example in the Innmind ecosystem are the [filesystem](../getting-started/operating-system/filesystem.md) properties. [`innmind/filesystem`](https://github.com/Innmind/Filesystem) has 2 implementations of its `Adapter` interface, a real implementation and an in memory one, and both implementations are tested against the same properties. [`innmind/s3`](https://github.com/Innmind/S3) also has implementation of `Adapter` and simply uses the filesystem properties to make sure implementations can be swapped by a user without a change in behaviour.

The [ORM](../getting-started/orm/index.md) also uses properties to make sure its 3 storage implementations behave exactly the same way.

To learn more about them head to the [BlackBox package documentation](https://github.com/Innmind/BlackBox/).
