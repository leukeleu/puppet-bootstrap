#!/usr/bin/env bash
#
# Bootstrap Puppet on Ubuntu 12.04 LTS
#
set -e

# Load up the release information
. /etc/lsb-release

REPO_DEB_URL="https://raw.github.com/leukeleu/puppet-bootstrap/master/apt.puppetlabs.com/puppetlabs-release-${DISTRIB_CODENAME}.deb"
# REPO_DEB_URL="https://apt.puppetlabs.com/puppetlabs-release-${DISTRIB_CODENAME}.deb"

PUPPET_SOURCE="https://github.com/leukeleu/puppet-bootstrap.git"

#------------------------------------------------------------------------------

if [ "$EUID" -ne "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# Initial apt-get update and upgrade
echo "Initial apt-get update and upgrade..."
apt-get update >/dev/null
apt-get upgrade -y >/dev/null

# Install latest Puppet from (local) PuppetLabs repo
echo "Configuring PuppetLabs repo..."
repo_deb_path=$(mktemp)
wget --output-document=${repo_deb_path} ${REPO_DEB_URL} 2>/dev/null
dpkg -i ${repo_deb_path} >/dev/null
apt-get update >/dev/null

echo "Installing Puppet..."
apt-get install -y puppet >/dev/null

echo "Installing git..."
apt-get install -y git >/dev/null
