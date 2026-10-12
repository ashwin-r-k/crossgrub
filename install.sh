#!/bin/bash

set -e

D=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
GRUB_DEFAULTS=/etc/default/grub
GRUB_THEME='GRUB_THEME=/boot/grub/themes/crossgrub/theme.txt'
GRUB_DISABLE_MEMTEST='GRUB_DISABLE_MEMTEST=true'

if [ "$(whoami)" != 'root' ]; then
    echo 'Script needs to be run as root.'
    exit 1
fi

cd /boot/grub/themes/
rm -rf crossgrub
mkdir -p crossgrub
cd crossgrub
cp "$D"/assets/*.png "$D"/theme.txt "$D"/*.pf2 .

if [ ! -f "$GRUB_DEFAULTS" ]; then
    echo "GRUB configuration not found: $GRUB_DEFAULTS"
    exit 1
fi

if ! grep -Fqx "$GRUB_THEME" "$GRUB_DEFAULTS"; then
    printf '\n%s\n' "$GRUB_THEME" >> "$GRUB_DEFAULTS"
    echo "Added Crossgrub theme to $GRUB_DEFAULTS"
else
    echo "Crossgrub theme is already configured in $GRUB_DEFAULTS"
fi

if grep -Eq '^[[:space:]]*GRUB_DISABLE_MEMTEST=' "$GRUB_DEFAULTS"; then
    sed -i 's/^[[:space:]]*GRUB_DISABLE_MEMTEST=.*/GRUB_DISABLE_MEMTEST=true/' "$GRUB_DEFAULTS"
    echo "Disabled Memtest entries in $GRUB_DEFAULTS"
else
    printf '\n%s\n' "$GRUB_DISABLE_MEMTEST" >> "$GRUB_DEFAULTS"
    echo "Disabled Memtest entries in $GRUB_DEFAULTS"
fi

if command -v update-grub &>/dev/null; then
    update-grub
elif command -v grub-mkconfig &>/dev/null; then
    grub-mkconfig -o /boot/grub/grub.cfg
else
    echo 'Neither update-grub nor grub-mkconfig was found; cannot update the GRUB configuration.'
    exit 1
fi

echo 'Installed Crossgrub and updated the GRUB configuration.'
