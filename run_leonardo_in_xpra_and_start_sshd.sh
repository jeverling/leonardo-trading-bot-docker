#!/bin/bash

# we want to start leonardo as unprivileged user, but sshd has to be run as root
sudo -i -u leonardo bash << EOF
    xpra start :123 --start-child=/home/leonardo/leonArdo-linux/run-leonArdo.sh &
EOF

/usr/sbin/sshd -D
