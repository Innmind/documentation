# Lab station

A [CLI tool](https://github.com/innmind/labstation/) to automatically run [PHPUnit](https://phpunit.de) tests, [Psalm](https://psalm.dev) and [PHP CS Fixer](https://github.com/FriendsOfPhp/PHP-CS-Fixer) when the source, tests, fixtures or properties change in the working directory. If you're on macOS it will automatically tell you if the commands failed or succeeded so you only have to look at your terminal when it fails.

On start it also ask if you want to update your dependencies and generate the [dependencies graph](dependency_graph.md).
