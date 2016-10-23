#!/bin/bash

# Rubens Franco - 2016
# ===============================================================================
# the script will run the proper playbook for rsyncing ca.pub and revoked files 
# in all servers present in 'ca-key-sync.yml' file.
# ===============================================================================

play_path="/opt/ansible"

# Sync the necessary files to your hosts
ansible-playbook ${play_path}/ca-key-sync.yml -i ${play_path}/hosts 
