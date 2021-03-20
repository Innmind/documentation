# Dependency graph

This is a small [CLI tool](https://github.com/Innmind/DependencyGraph) to generate graphs (via [graphviz](https://graphviz.org)) to help understand the dependencies/dependents relations of the packages of the organization. The initial goal being to know all the packages that need to be updated when a package release a new major version.

The tool can show:
- the full dependency graph of an organization
- the dependencies of a particular package
- the dependents of a particular package within an organization
- the dependency graph from a `composer.lock`
