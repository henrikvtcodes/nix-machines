# !/bin/bash
sleep 2

gum

if [ $? -eq 0 ]; then
  gum log --level="debug" "Gum installed."
else
  nix-env -iA nixos.gum
fi

# Check if the user is root
if [ "$EUID" -ne 0 ]; then
  gum log --level="fatal" "Please run as root."
  exit 1
fi

# Partition and mount the boot drive
nix \
  --experimental-features "nix-command flakes" \
  run github:nix-community/disko -- \
  --mode disko /tmp/disk-config.nix

if [ $? -eq 0 ]; then
  gum log --level="info" "Disko partitioning successful."
else
  gum log --level="fatal" "Disko partitioning failed."
  exit 1
fi

# Generate the nixos configuration
gum log --level="debug" "Generating NixOS configuration."
nixos-generate-config --no-filesystems --root /mnt

if [ $? -eq 0 ]; then
  gum log --level="info" "NixOS configuration generated."
else
  gum log --level="fatal" "NixOS configuration generation failed."
  exit 1
fi

# Copy the temporary config to the mounted drive
cp /tmp/disko-config.nix /mnt/etc/nixos/disk-config.nix

# Download the repo init config and replace it the generated one
rm -f /mnt/etc/nixos/configuration.nix
curl -o /mnt/etc/nixos/configuration.nix https://raw.githubusercontent.com/henrikvtcodes/nix-machines/main/init/configuration.nix

gum log --level="info" "Configuration files copied to /mnt/etc/nixos."

function install() {
  echo "Running nixos-install --root /mnt"
  nixos-install --root /mnt
  if [ $? -eq 0 ]; then
    gum log --level="info" "Installation successful."
  else
    gum log --level="fatal" "Installation failed."
    exit 1
  fi

  gum confirm "Reboot now?"

  if [ $? -eq 0 ]; then
    gum spin --spinner line --title "Rebooting..." -- sleep 3
    reboot
  else
    gum log --level="error" "Reboot manually."
  fi
}

function dontInstall () {
  gum log --level="error" "Not installing. Exiting."
  exit 1
}

gum confirm "Run Install?"

if [ $? -eq 0 ]; then
  install
else
  dontInstall
fi