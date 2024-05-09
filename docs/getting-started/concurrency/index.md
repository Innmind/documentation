# Concurrency

Concurrency is about executing multiple parts of a program in way to waste as little time as possible. There is 2 ways possible to achieve this:

- asynchronity
- parallelism

Asynchronous code means there are at all times only one part of a program that's executed. But each part of the program advances ones after the other in the same process. This mode is useful when your program is I/O bound, for example if a part of your program makes an HTTP call then another part can be executed while you wait for the response. However if your program is CPU bound then this mode has no usefulness.

Parallel code means that multiple processes will be executed at the same time. Each process will be spread across the cores available on your CPU. This mode is useful when your program is CPU bound. But it comes with the disadvantage of coordinating the results of each process (when needed).

!!! success ""
    Innmind offers solutions for both needs.
