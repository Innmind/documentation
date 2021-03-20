# Goals

Since its beginning this organization has been about being a playground to improve my coding skills and test new ways to code.

To continue to improve the code and test new techniques all the packages are built around a single project. Initially this project was to build a web crawler _to download internet_ (it started as a joke when I was a student) but has now merged with another interest of mine: consciousness.

**Note**: you can read more about this [here (in french)](https://github.com/Innmind/Research-N-Development/blob/master/Papers/Sur%20la%20conscience.md)

## Short term

The current goal is to build enough abstraction to move away from low level details (and the quirks of PHP) and to help concentrate to higher behaviours that the project needs to fulfill.

This is done via packages like [`operating-system`](https://github.com/Innmind/operatingsystem), [`http-server`](https://github.com/Innmind/httpserver) or [`cli`](https://github.com/Innmind/cli). They've been heavily inspired from other languages such as [Scala](https://scala-lang.org) or [Pony](https://www.ponylang.io).

More packages will come in the future, and existing ones impoved, to help build the other goals.

## Mid term

The first concrete goal is going to run the applications [`library`](https://github.com/innmind/library/) and [`crawler-app`](https://github.com/innmind/crawlerapp/) at scale. It needs to run without supervision and heal itself in case of failures (it may be done by rewriting them with the actor model).

It needs to take care of itself to understand if it can replicate a living organism behaviour by adapting to its environment to keep itself _alive_. In the case it can indeed run forever then I'll need to research if the strategies it uses are similar to the organic world and if so opens the possibilites of the long term goals.

## Long term

If the mid term goals are successful then the next step will be to understand and try to replicate the evolution of mechanism that can lead to consciousness. This will be done by following theories from [Antonio Damasio](https://en.wikipedia.org/wiki/Antonio_Damasio) as described in the [article](https://github.com/Innmind/Research-N-Development/blob/master/Papers/Sur%20la%20conscience.md) linked at the start.
