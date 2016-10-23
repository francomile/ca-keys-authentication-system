#!/bin/bash

# Rubens Franco - 2016
# =================================================================================
# this script will setup the CA signing authentication 
# on all client servers by running the ca-key-setup.yml playbook against all hosts.
# =================================================================================

play_path="/opt/ansible"

echo "Against which host do you want to run this setup? "
echo "Please separate hostnames with a coma: myhost1.tld,myhost2.tld,myhostgroup.tld "
echo ""
read hostnames

# Run the Setup
ansible-playbook ${play_path}/ca-keys-setup.yml -i ${play_path}/hosts  --limit "${hostnames}"



