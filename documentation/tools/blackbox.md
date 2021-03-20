# BlackBox

This a [testing library](https://github.com/innmind/blackbox/) to to [Property Based Testing](https://hypothesis.works/articles/what-is-property-based-testing/) with [PHPUnit](https://phpunit.de).

This project was born since [`giorgiosironi/eris`](https://packagist.org/packages/giorgiosironi/eris) seem to no longer be maintained.

For short the goal is to test a code for all possible combinations of inputs it accept instead of the traditional use cases.

It's also a good way to write expected behaviour once and test multiple instances to make sure all of them respect the expected behaviour. This is really useful for packages' maintainers as end users may extend the package and easily test it doesn't break the behaviours.

