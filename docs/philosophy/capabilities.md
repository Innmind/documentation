# Capabilities

[Ambient authority](https://en.wikipedia.org/wiki/Ambient_authority) is the ability to call the system (1) from anywhere in your program.
{.annotate}

1. such as `fopen`

On the other hand [Capabilities](https://en.wikipedia.org/wiki/Capability-based_security) is a way to represent a resource we have access to, and is given to us. We cannot access it directly.

These designs are security models inside programs.

Innmind focuses more on the system access side more than the security one.

In essence the capabilities approach is about dependency injection on all things concerning the operating system.

That's why the [Operating System](../getting-started/operating-system/index.md) abstraction is central in the ecosystem.
