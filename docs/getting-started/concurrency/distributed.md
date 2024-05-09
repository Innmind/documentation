# Distributed

Innmind intends to provide a way to build distributed programs with the same philosophy seen so far.

This way you'll be able to move to a distributed program with little effort.

## Actor Model

The [Actor Model](https://en.wikipedia.org/wiki/Actor_model) is a way to build concurrent programs. It's built arount 3 concepts:

- an Actor is a compute unit that handle state
- an Actor can create actors
- an Actor can send/receive messages

An actor can only receive one message at a time, meaning there's no concurrency on a single actor. This simplify drastically the complexity of handling state and eliminate data races.

The concurrency as a whole is handled by the tree of actors that spread the work.

!!! abstract ""
    You can think of this model as a queuing system that dynamically create new queues.

But because having one process per actor would be too expensive in resources, it's required to be able to run multiple actors asynchronously inside a single process. Hence all the tools you've seen previously.

## Work in progress

The implementation of this model is still underway at [`innmind/witness`](https://github.com/Innmind/witness).

There's been quite a gap in activity on this repository because early work on the implementation revealed that the use of exceptions was untenable for the system stability.

!!! info ""
    This is what motivated the move to the monadic approach across all Innmind packages.
