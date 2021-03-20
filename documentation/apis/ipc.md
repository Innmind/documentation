# Inter Process Communication (IPC)

This is an [abstraction](https://github.com/innmind/ipc/) on top of [`operating-system`](operating_system.md) to help communicate over a socket between PHP processes.

The communication protocol has been inspired from the [amqp](https://github.com/innmind/amqp/) one so it incorporates message acknowledgements and heartbeats.

Usage of this package can be found in the [Silent cartographer](../tools/silent_cartographer.md) or [Kalmiya](../tools/kalmiya.md) to communicate between the [CLI](https://github.com/Innmind/Kalmiya/blob/develop/src/Command/Music/Authenticate.php#L63) and an [HTTP server](https://github.com/Innmind/Kalmiya/blob/develop/src/RequestHandler/AppleMusic.php#L90) for the login process to [Apple Music](https://github.com/musiccompanion/AppleMusic/).
