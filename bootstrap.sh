#!/usr/bin/env bash
#
# Bootstrap Puppet on Ubuntu 12.04 LTS
#
set -e

# Load up the release information
. /etc/lsb-release

REPO_DEB_URL="https://raw.github.com/leukeleu/puppet-bootstrap/master/apt.puppetlabs.com/puppetlabs-release-${DISTRIB_CODENAME}.deb"
# REPO_DEB_URL="https://apt.puppetlabs.com/puppetlabs-release-${DISTRIB_CODENAME}.deb"

PRIVATE_REPO_URL="git@github.com:leukeleu/puppet-server-base.git"

#------------------------------------------------------------------------------

# Install latest Puppet from (local) PuppetLabs repo
echo "Configuring PuppetLabs repo..."
repo_deb_path=$(mktemp)
wget --output-document=${repo_deb_path} ${REPO_DEB_URL} 2>/dev/null
sudo dpkg -i ${repo_deb_path} >/dev/null
sudo apt-get update >/dev/null

echo "Installing Puppet..."
sudo apt-get install -y puppet >/dev/null

echo "Installing git..."
sudo apt-get install -y git >/dev/null

# Ask for the location of the private Puppet repository
read -e -p "Enter the location of the private Puppet repository: " -i "${PRIVATE_REPO_URL}" PRIVATE_REPO_URL

# Give current user access to the private Puppet repository
if [ ! -d ~/.ssh ]; then
  mkdir ~/.ssh && chmod 700 ~/.ssh
fi
if [ ! -f ~/.ssh/id_rsa ]; then
  echo "Generating SSH key..."
  ssh-keygen -N '' -f ~/.ssh/id_rsa
fi

# Ask for public key to be added as a deploy key to the private Puppet repository
echo -e "Please add this public key as a deploy key at ${PRIVATE_REPO_URL}, then press any key to continue.\n"
cat ~/.ssh/id_rsa.pub
read -n 1 -s

# Fetch private Puppet repository into current user's directory
if [ ! -d ~/etc/puppet/.git ]; then
  echo "Fetching private Puppet repository..."
  mkdir -p ~/etc/puppet && git clone ${PRIVATE_REPO_URL} ~/etc/puppet
fi

# Bootstrap Puppet
echo "Bootstrapping Puppet..."
sudo puppet apply --modulepath=~/etc/puppet/modules ~/etc/puppet/manifests/init.pp
