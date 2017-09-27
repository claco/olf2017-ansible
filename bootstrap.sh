#!/usr/bin/env bash


################################################################################
# Stop on errors
################################################################################
set -e


################################################################################
# Set default variables
################################################################################
GIT_REPOSITORY_NAME=${GIT_REPOSITORY_NAME:=olf2017-ansible}
GIT_REPOSITORY_OWNER=${GIT_REPOSITORY_OWNER:=claco}
GIT_REPOSITORY_URL=${GIT_REPOSITORY_URL:-https://github.com/$GIT_REPOSITORY_OWNER/$GIT_REPOSITORY_NAME.git}
GIT_CHECKOUT_DIRECTORY=${GIT_CHECKOUT_DIRECTORY:-$HOME/Projects/$GIT_REPOSITORY_NAME}


################################################################################
# Ask for and persist sudo up front
################################################################################
sudo -v

while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


################################################################################
# Discovery distro to install Ansible accordingly
################################################################################
if [ -x "$(command -v lsb_release)" ]; then
  DIST=`lsb_release -si`
else
  DIST=""
fi


################################################################################
# Ubuntu Ansible Installation
################################################################################
if [[ "$DIST" == "Ubuntu" ]]; then
  if [ ! -f /usr/bin/ansible-playbook ]; then
    printf "Installing Ansible..."

    sudo apt-add-repository -y ppa:ansible/ansible &> /dev/null
    sudo apt -y update &> /dev/null
    sudo apt -y install ansible git sshpass &> /dev/null

    echo "done"
  else
    echo "Ansible already installed...skipping"
  fi
fi


################################################################################
# OSX Ansible Installation
################################################################################
if [[ "$DIST" == "" ]]; then
  export HOMEBREW_CASK_OPTS="--appdir=/Applications --fontdir=/Library/Fonts"


  ##############################################################################
  # Command Line Tools Installation
  ##############################################################################
  if ! pkgutil --pkg-info=com.apple.pkg.CLTools_Executables &> /dev/null; then
    printf "Installing Command Line Tools..."
    xcode-select --install &> /dev/null || true
    while ! pkgutil --pkg-info=com.apple.pkg.CLTools_Executables &> /dev/null; do
      sleep 10
    done
    echo "done"
  else
    echo "Command Line Tools already installed...skipping"
  fi


  ##############################################################################
  # Homebrew Interactive Installation
  ##############################################################################
  if [ ! -f /usr/local/bin/brew ]; then
    echo "Installing Homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install brew-cask-completion
    brew cask install caskroom/fonts/font-symbola
  else
    echo "Homebrew already installed...skipping"
  fi


  ##############################################################################
  # Homebrew Ansible Installation
  ##############################################################################
  if [ ! -f /usr/local/bin/ansible-playbook ]; then
    printf "Installing Ansible..."
    brew install ansible &> /dev/null
    echo "done"
  else
    echo "Ansible already installed...skipping"
  fi


  ##############################################################################
  # Enable SSH Logins
  ##############################################################################
  if [[ $(sudo systemsetup -getremotelogin) = *Off* ]]; then
    printf "Enabling Remote Login..."
    sudo systemsetup -setremotelogin on
    echo "done"
  else
    echo "Remote Login Enabled ...skipping"
  fi
fi


################################################################################
# Clone Ansible Playbooks
################################################################################
if [ ! -d $GIT_CHECKOUT_DIRECTORY/.git ]; then
  printf "Cloning Playbooks..."
  mkdir -p $GIT_CHECKOUT_DIRECTORY
  git clone $GIT_REPOSITORY_URL $GIT_CHECKOUT_DIRECTORY &> /dev/null
  echo "done"
else
  echo "Playbooks already cloned...skipping"
fi
