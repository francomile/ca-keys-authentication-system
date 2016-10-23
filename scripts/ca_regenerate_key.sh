#!/bin/bash

# Rubens Franco - 2016
# ==================================================================================
# This script will regenerate a new CA signing key for signing your public keys, and 
# if user choose so, it will sync the new.
# Only use this script if you want to generate a new 'ca' key for 
# signing the user's public keys. This is only required if you think your old ca key was compromised.
# ==================================================================================

clear

# Variables
timest=$(date +%s)
backup_dir="/etc/ssh/ca-keys-backups"
key_signer="/etc/ssh/key_signer"

# Make sure you're root before you can run the script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root, exiting..." 1>&2
   exit 1
fi

# Ask the user for confirmation
echo "This script will regenerate your CA keys, which will invalidate all old signed public keys from users across your servers."
read -r -p "Are you sure you want to proceed?  [Y/y] Yes [N/n] No  "
# Proceed
case $answer in
    [yY][eE][sS]|[yY])

        # Backup keys_signer together with the old ca keys
        [ -d "$backup_dir" ] || mkdir $backup_dir
        echo "Backing up old CA keys into ${backup_dir}"
        tar -cf ${backup_dir}/ca-backup-${timest}.tar  $key_signer &>/dev/null

        # Regenerate ca keys
        /usr/bin/ssh-keygen  -C CA -f ${key_signer}/ca -q -N ""

        if [ "$?" -eq 0 ]; then
              echo "The new ca signing key was successfuly created"
              cp ${key_signer}/ca.pub /etc/ssh && chmod 644 /etc/ssh/ca.pub

              # Ask if should sync the new ca.pub file
              read -r -p "Do you want to sync the new ca.pub key to all the remote servers? [Y/y] Yes [N/n] No " awnser
                  case $answer in
                    [yY][eE][sS]|[yY])
                        echo "syncing new files to remote servers..."
                        /usr/local/bin/ca_sync.sh
                    ;;
                    [nN][oO]|[nN])
                        echo "You've choosed not to sync the new ca.pub file. All done then, Bye"
                        exit 0
                    ;;
                    *)
                        echo "Invalid input... Exiting"
                        exit 1
                    ;;
                  esac
          else
            echo "The key was not generated, please check or try again"
            exit 1
        fi

    ;;
    [nN][oO]|[nN])
        echo "You've choosed not to regenerate the CA keys. All done then, Bye"
        exit 0
    ;;
    *)
        echo "Invalid input... Exiting"
        exit 1
    ;;
esac

