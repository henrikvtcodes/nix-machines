# !/bin/bash
sleep 2

sudo mkdir -p /mnt/etc/nixos
# Generate the base config
sudo nixos-generate-config --no-filesystems --root /mnt

# Download the disko configuration to /mnt/etc/nixos
rm -vf /mnt/etc/nixos/disk-config.nix
sudo curl -o /mnt/etc/nixos/disk-config.nix https://raw.githubusercontent.com/henrikvtcodes/nix-machines/main/init/disk-config.nix

# # Prompt the user for which drive to install to:
# echo "Which drive would you like to install to? (e.g. /dev/sda)"
# read -p "Drive: " DRIVE

# # Set the drive in the configuration
# sudo sed -i "s|to-be-filled-during-installation|$DRIVE|" /mnt/etc/nixos/disk-config.nix

# Overwrite the configuration.nix with the provided configuration
rm -vf /mnt/etc/nixos/configuration.nix
sudo curl -o /mnt/etc/nixos/configuration.nix https://raw.githubusercontent.com/henrikvtcodes/nix-machines/main/init/configuration.nix

# Finish by letting the user know what to do next
echo "Script completed"
echo "Make sure to check /mnt/etc/nixos/disk-config.nix to ensure the correct device is set"
echo "Next, run sudo nixos-install --root /mnt"