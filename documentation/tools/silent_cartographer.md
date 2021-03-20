# Silent cartographer

Both a [CLI tool](https://github.com/innmind/silentcartographer/) and a library to send all the system calls (done through [`operating-system`](https://github.com/innmind/operatingsystem)) to the CLI interface so ass a user you can see all the activity happening on your machine.

The initial goal was to understand what is happening inside the workers of the [Crawler](../applications/crawler.md) since they often wait before crawling a website (as they respect the `Crawl-Delay` directive from the `robots.txt`).

**Note**: internally it uses the [`ipc`](https://github.com/innmind/ipc/) package so there is no trace left on disk when the CLI interface is closed.
