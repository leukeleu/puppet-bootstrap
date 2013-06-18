Puppet bootstrap
================

First, make sure your packages are up to date:

    sudo apt-get update
    sudo apt-get upgrade

Execute the following command as a user who is a sudoer:

    wget -O - https://raw.github.com/leukeleu/puppet-bootstrap/master/bootstrap.sh 2>/dev/null | /usr/bin/env bash
