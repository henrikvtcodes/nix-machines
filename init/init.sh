# !/usr/bin/env bash
mkdir -p /mnt/etc/nixos

# Generate the base config
nixos-generate-config --no-filesystems --root /mnt

# Download the disko configuration to /mnt/etc/nixos
curl -o /mnt/etc/nixos/disk-config.nix https://raw.githubusercontent.com/henrikvtcodes/nix-machines/main/init/disk-config.nix
# Prompt the user for which drive to install to
echo "Which drive would you like to install to?"
lsblk
read -r DRIVE

# Set the drive in the configuration
sed -i "s|to-be-filled-during-installation|/dev/$DRIVE|" /mnt/etc/nixos/disk-config.nix

# Overwrite the configuration.nix with the provided configuration
curl -o /mnt/etc/nixos/configuration.nix https://raw.githubusercontent.com/henrikvtcodes/nix-machines/main/init/configuration.nix

# Finish by letting the user know what to do next
echo "Script completed"
echo "Next, run sudo nixos-install --root /mnt"