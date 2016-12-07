#Remote Code Server
_(Not at all related to the erlang code server)_

An elixir program that lets users access and execute functions from a remote machine over a TCP connection.

## About
This is a tiny project just for fun.

There is absolutely no guarantee of security.

Untested with more users than 1 (one).

## Intended functionality
Consists of three main components.

1. A file poller that scans a directory for source files or BEAM binaries. When a new module is added, the exported functions of this module becomes available for remote users.
2. A server for regular clients to connect. A client can execute the following commands over TCP:
  - list - Lists all of the available modules and functions
  - info [module] - Lists all of the exported functions of [module], as well as the md5sum of the .beam
  - info [module] md5 - Gives the md5sum of [module]
  - info [module] exported - Gives the exported functions of [module]
  - md5 [module] - Gives the md5sum of the beam for [module]
  - run [Module] [Function] [Args] - Executes a function and gives the user the return value over TCP
  - help - Prints help about commands
3. A server for superusers to connect. A superuser can execute the same commands that a client can, but has a few superpowers.
  - delete [module] - Deletes the .beam for [module]
  - restrict [module] - Makes it impossible to use and/or list information about [module]
  - restrict [module] [function] - Makes it impossible to use and/or see information about [function] when getting info about [module]
  - blacklist [IP] - Makes it impossible for any user with the IP [IP] to connect to a client port.

## Finished functionality
- A file poller that scans a directory for files every now and then. It doesn't do anything with said files, however.