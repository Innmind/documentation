# Property Based Testing

## Description

Instead of writing tests like:

> When I run this code with this value X then I should get back the value Y.

You'd do:

<div class="annotate" markdown>
> When I run this code with any value of type X then this property (1) is true.
</div>

1. Here _property_ is used in the general sense, not as an _object property_.

The advantage of writing tests this way is that we define the _range of values_ that should make the test pass. It's then up to the framework to generate the values within this range and run your test multiple times to make sure the test pass.

This means that the testing framework constantly run new scenarii for your tests. The more you run your tests the more confidance you have that your code is correct.

!!! success ""
    The goal is to make sure your implementation is correct in all possible scenarii. And it also has the side effect to making your tests less brittle

## Examples

### Math `add` function

This is the _go to_ example to introduce this technique as this function is easy to understand and only have 3 properties:

=== "Commutative"
    This means that you can change the order of arguments and still get the same result.

    In pseudo code a test whould look like:
    ```php
    function testCommutative(int $a, int $b) {
        assertSame(
            add($a, $b),
            add($b, $a),
        );
    }
    ```

=== "Cumulative"
    This means that no matter the order of operations you still get the same result.

    In pseudo code a test whould look like:
    ```php
    function testCumulative(int $a, int $b, int $c) {
        assertSame(
            add($a, add($b, $c)),
            add(add($a, $b), $c),
        );
    }
    ```

=== "`0` is an identity value"
    This means that if you add `0` to any other value it returns the same value.

    In pseudo code a test whould look like:
    ```php
    function testIdentityValue(int $a) {
        assertSame(
            $a,
            add($a, 0),
        );
    }
    ```

With this 3 properties you virtually cover all possible operations that could be run. And this makes the implementation of `add` very hard to get wrong.

### More realistic example

This kind of example is rarely the kind of things you'll have to test in a real program.

A more concrete example that exists in many programs is user registration/login. Let's say that the registration workflow is a new user comes in and register, a confirmation email is sent, and once confirmed the user can login.

The properties that you would have to verify are:

- Any new user (pair of identifier and password strings) can register
- Any new user can't login by default
- Any new user can't register twice
- A user can login after clicking the email confirmation link

The first one verifies you can accept any pair of strings (no crash of your program). The second verifies the registration is partial and an extra step is required in order to login. The thirs one prevents duplicates in your database and sending multiple emails that would confuse the user. And the last one makes sure that it's the email extra step that allows the user to login.

To find the properties of a system look for business rules that are **always** true. Do not try to put the whole business rules inside a single property. It's the combination of them that makes sure the system is correct.
