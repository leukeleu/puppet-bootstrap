#!/usr/bin/env bash
#
# Bootstrap Puppet on Ubuntu 16.04 LTS.
#
set -e

# Load up the release information
. /etc/lsb-release

REPO_DEB_URL="https://apt.puppetlabs.com/puppetlabs-release-pc1-${DISTRIB_CODENAME}.deb"

PRIVATE_REPO_URL="git@github.com:leukeleu/puppet-server-base.git"

#--------------------------------------------------------------------
# NO TUNABLES BELOW THIS POINT
#--------------------------------------------------------------------

# Do the initial apt-get update
echo "Initial apt-get update..."
sudo apt-get update >/dev/null

# Install the PuppetLabs repo
echo "Configuring PuppetLabs repo..."
repo_deb_path=$(mktemp)
wget --output-document="${repo_deb_path}" "${REPO_DEB_URL}" 2>/dev/null
sudo dpkg -i "${repo_deb_path}" >/dev/null
sudo apt-get update >/dev/null

# Install Puppet
echo "Installing Puppet..."
DEBIAN_FRONTEND=noninteractive sudo apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install puppet >/dev/null

echo "Puppet installed!"

#--------------------------------------------------------------------
# Leukeleu custom bits
#--------------------------------------------------------------------

echo "Installing software-properties-common..."
sudo apt-get -y install software-properties-common >/dev/null

echo "Installing build-essentials..."
sudo apt-get install -y build-essential >/dev/null

echo "Installing git..."
sudo apt-get install -y git >/dev/null

echo "Installing system updates..."
sudo apt-get upgrade -y >/dev/null

echo "Installing librarian-puppet..."
sudo gem install librarian-puppet -v 2.2.3 >/dev/null

# Ask for the location of the private Puppet repository
read -e -p "Enter the location of the private Puppet repository: " -i "${PRIVATE_REPO_URL}" PRIVATE_REPO_URL </dev/tty

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
read -n 1 -s </dev/tty

# Fetch private Puppet repository into current user's directory
if [ ! -d ~/etc/puppet/.git ]; then
  echo "Fetching private Puppet repository..."
  mkdir -p ~/etc/puppet && git clone ${PRIVATE_REPO_URL} ~/etc/puppet
fi

# Add aliases
echo -e $'alias puppet-update=\'bash -c \"if [ -d ~/etc/puppet-manifests ]; then cd ~/etc/puppet-manifests && (git pull -q || true); fi && cd ~/etc/puppet/ && (git pull -q || true) && librarian-puppet install --quiet && echo \\\"Done!\\\"\"\'' > ~/.bash_aliases
echo "alias puppet-apply='sudo bash -c \"FACTER_user=\$USER puppet apply --confdir=~/etc/puppet --modulepath=~/etc/puppet/modules/ops:~/etc/puppet/modules/dev:~/etc/puppet/modules/lib --manifest=~/etc/puppet/manifests ~/etc/puppet/manifests\"'" >> ~/.bash_aliases
source ~/.bash_aliases

# Bootstrap Puppet
echo "Please reboot, and then run 'puppet-update && puppet-apply' with the correct branch of the private Puppet repository."
