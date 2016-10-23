#!/bin/bash

# Rubens Franco - 2016
# ==================================================
# Setup script for the CA machine
# this script must be at the root of the repository
# ==================================================


# Set the pretty colours for use:
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
cyan='\033[0;36m'

# Resets the style
reset=`tput sgr0`

# Color-echo.
# arg $1 = message
# arg $2 = Color
cecho() {
  echo "${2}${1}${reset}"
  return
}


# Variables
ssh_path=/etc/ssh
key_signer=/etc/ssh/key_signer
auth_path=/etc/ssh/auth_principals
play_path=/opt/ansible
script_files=scripts/*
playbooks=ansible-playbooks/*
# users array
users[1]="webmaster"
users[2]="dbmaster"
users[3]="admin"


# Make sure you're root before you can run the script
if [[ $EUID -ne 0 ]]; then
   cecho "This script must be run as root, exiting..." $red 1>&2
   exit 1
fi

cecho "========================================================" $green
cecho "======> STARTING SETUP SCRIPT FOR CA MAIN SERVER <======" $green
cecho "========================================================" $green
echo ""


# Install some packages
cecho "======> Installing some usefull packages ..." $green
apt-get update && apt-get upgrade -y
apt-get install curl wget python-software-properties vim dnsutils build-essential git bash-completion git-extras rsync

# Install Ansible on the machine
cecho "======> Installing Ansible ..." $green
apt-get install python-setuptools python-pip && pip install paramiko PyYAML Jinja2 httplib2 six && pip install ansible


# Create the necessary directories and files:
cecho "======> Creating directories and necessary files" $green
# key_signer directory
[ -d "$key_signer" ] || mkdir $key_signer
# auth_principals directory
[ -d "$auth_path" ] || mkdir $auth_path
# The ansible directory
[ -d "$play_path" ] || mkdir $play_path
# The ansible hosts file
[ -f "${play_path}/hosts" ] || touch ${play_path}/hosts
# User's files
[ -f "${auth_path}/${users[@]}" ] || touch ${auth_path}/${users[@]}
# revoked_keys file
[ -f "${ssh_path}/revoked_keys" ] || touch ${ssh_path}/revoked_keys
# signed_keys file
[ -f "${ssh_path}/signed_pubkeys" ] || touch ${ssh_path}/signed_pubkeys


# Install the scripts
cecho "======> Installing the CA scripts in /usr/local/bin ..." $green
for f in $script_files 
    do
        cp  $f  /usr/local/bin
        chmod ug+rwx /usr/local/bin/$i 
done


# Install the Ansible roles
cecho "======> Installing the Ansible roles in /opt/ansible ..." $green
cp -r $playbooks/*  $play_path


# Generate CA key
cecho "======> Generation CA keys for signing your SSH public keys..." $green
/usr/bin/ssh-keygen -C CA -f ${key_signer}/ca -q -N ""
if [ "$?" -eq 0 ]; then
        cecho "======> The new ca signing key was successfuly created" $green
        cp ${key_signer}/ca.pub /etc/ssh && chmod 644 /etc/ssh/ca.pub
        echo ""
        cecho "========================================================" $green
        cecho "======>              FINISHED SETUP              <======" $green
        cecho "========================================================" $green
    else
        echo "The key was not generated, please check or try again"
        exit 1
fi



