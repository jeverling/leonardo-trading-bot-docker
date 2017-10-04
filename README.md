# Introduction

This repository contains a Dockerfile that builds an image running the leonArdo trading bot: [http://marginsoftware.de/product.html](http://marginsoftware.de/product.html).

It runs the bot inside a [xpra](http://xpra.org/) session, together with a SSH server. You can connect using [xpra](http://xpra.org/) or [winswitch](http://winswitch.org).

This image is useful when you want to run the bot on a remote machine like a VPS or if the application doesn't work correctly on your system (e.g. due to conflicting QT libraries).

The password for the `leonardo` user that is created by the Dockerfile and that can be used to access via SSH is `leonardo`. Obviously this has to be changed if you plan to bind the container SSH port to anything else than `localhost`!
<br>
I recommend using SSH forwarding instead, e.g. open a tunnel with `ssh -L 2222:localhost:2222 user@remote-host-where-the-container-runs` and then connect to `localhost` (see usage below).

I had a problem on a VPS where Leonardo wouldn't start, so the Dockerfile contains a workaround that worked for me, it simply inserts a `sync` in the `run-leonArdo.sh` script.

The config directory `/home/leonardo/.leonardo` inside the container is a `VOLUME`, so it will bypass the ephemeral Docker filesystem. If you plan on using this image you should either run it with `docker-compose.yml` so the volume is always used by new containers and/or mount the config directory from the Docker host's filesystem.  


The Dockerfile could be improved (for example by using [guacamole](http://guacamole.incubator.apache.org/)) but it works for me and maybe it will be useful for others as well.


## Usage

To run the bot locally:

`sudo docker run -d --name leonardo -p 127.0.0.1:2222:22 jeverling/leonardo-trading-bot`

Then attach to the xpra server:

`xpra attach ssh:leonardo@localhost:2222:123`

This should show the login screen of *leonArdo*.

If you want to run the bot with an existing config, you can mount the config folder into the Docker container. Please note that you will have to make sure that the unprivileged `leonardo` user that is used inside the container is able to write to the files/folders. The easiest way to achieve that is to make the `~/.leonardo` directory accessible to *others*, e.g. `chmod -vR 757 ~/.leonardo`.

To run the container with the existing config directory as a mount:

`sudo docker run -d --name leonardo -p 127.0.0.1:2222:22 -v /full/path/to/existing/.leonardo:/home/leonardo/.leonardo jeverling/leonardo-trading-bot`

If you plan on running the bot using this Docker image you should check out the `docker-compose.yml` file to run the container with *docker-compose*.
