# Design choices

All packages created in this organization are here to advance toward the [defined goals](goals.md) of the whole project. This means that all the APIs are designed to help this problem first. But they're also designed in a way so they can help other projects to solve recurring problems (since the [long term goal](goals.md#long-term) may not be reachable).

All packages evolution follow the same steps (always in this order):
- make it work
- make it simple
- make it fast

This organization puts an emphasis on the second step as it helps with another core principle:

> make it easy to use it right, make it hard to use it wrong

This results in APIs with very low use of primitive types as this strategy generally brings too many implicits. The resulting design is a mix between object oriented programming and functional programming (similar to [Scala](https://scala-lang.org) or [Pony](https://www.ponylang.io)).

The last step, `make it fast`, is not a real priority as there is still plenty of packages to build in order to reach the organization [goals](goals.md). However this doesn't mean speed is sacrified for the sake of simplicity.
