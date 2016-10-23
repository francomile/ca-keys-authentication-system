#!/bin/bash

# Rubens Franco - 2016
# ===============================================
# Script for signing  SSH public keys with CA key 
# ===============================================


## VARIABLES:
# Random number for serial:
n=$RANDOM
# The file where we'll be storing al the keys for posterior revoking if needed
keysfile=/etc/ssh/signed_pubkeys
# The name of final signed key
signedkey=id_rsa-cert.pub
# The path where the thing should take place
kspath=/etc/ssh/key_signer

# START SIGNING THE KEY...
clear
echo ""
echo "=========================================="
echo "           PUBLIC KEY SIGNER              "
echo "=========================================="
echo ""
echo ""
# Store the username
echo "what is the username for the key you wish to sign? " 
echo ""
read username
# Choose the public key to sign
echo "What is the public key file you wish to sign? (give me the full path) Any of these below? "
echo ""
basename $(ls  ${kspath}/*.pub | grep -v ca.pub) 
echo ""
read pubkey
echo ""
# Read the zone or role for the user
echo "Which will be the role or zone of this user (webmaster, admin, dbmaster, etc..)? " 
echo ""
read role
# Set te expiration time for the key
echo "Set the expiration time for this key. In the following format..." 
echo "number+[w] for weeks, and [d] for days. "
echo "eg: 2d = 2 Days, 52w = 1 Year, 26w = 6 Months..."
echo ""
read ntime
echo ""
echo ""
echo "=========================================="
echo "     GENERATING SIGNED PUBLIC KEY..."
echo "=========================================="
echo ""
echo ""

# First backup the original unsigned public key for further usage if needed
[ -d "${kspath}/orig_pubkeys" ] || mkdir ${kspath}/orig_pubkeys
cp ${kspath}/$pubkey  ${kspath}/orig_pubkeys/${username}-${pubkey}

# Sign the user's public key
ssh-keygen -s ${kspath}/ca -I $username -n $role -V +${ntime}  -z $n ${kspath}/$pubkey

if [ $? -eq 0 ];then
            echo " "
            cat ${kspath}/${signedkey}
            echo " "
            echo "============================================================== "
            echo "The Public Key ${kspath}/${signedkey} was successfully signed! "
            echo "============================================================== "
            echo " "
cat <<EOF >> $keysfile

=========================
$username public key:
=========================
EOF
            cat ${kspath}/${signedkey} >> $keysfile
            echo " " >> $keysfile
            echo "========== END OF KEY ========= " >> $keysfile
            mkdir ${kspath}/${username}-signed-keys
            mv ${kspath}/${signedkey} ${kspath}/${username}-signed-keys
            rm -f ${kspath}/${pubkey}
     else
            echo " "
            echo "There was a problem signing your key, please try again!"
            echo " "
            exit 1
fi
