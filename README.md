# Puppet bootstrap

## Requirements

- Ubuntu 12.04.5 LTS 64-bit


## Installation

Execute the following command as a user who is a sudoer:

    $ wget -O - https://raw.github.com/leukeleu/puppet-bootstrap/master/bootstrap.sh 2>/dev/null | /usr/bin/env bash


This will install git and Puppet, ask for a private Puppet repository, and bootstrap your system with it.

Later on, you can login as the same user and perform the following commands to update you puppet configuration

    $ puppet-update
    $ puppet-apply
