# Warden

A small [CLI tool](https://github.com/innmind/warden/) to automatically force the use of ssh keys to a server and add a user ssh key to the machine by fetching them from `github.com/{user}.keys`.

You can add the command to retrieve the public keys in a crontab so everytime you add a new ssh key to your GitHub account it's also added to the server.
