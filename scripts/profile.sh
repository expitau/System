#!/bin/bash
set -e

# Set USER variable if not set, this comes from build script. Default password is not a secret
USER=${USER:-user}
PW=$(echo "${PW:-Y0dGemMzZHZjbVE9}" | base64 --decode)

echo "Running custom install scripts..."
pacman-key --populate archlinux

# Enable multilib
cat <<EOF >> /etc/pacman.conf

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
pacman -Syyu --noconfirm

shopt -s extglob
pacman -U /usr/src/paru/paru-bin-!(d*).pkg.tar.zst --noconfirm

# System
systemctl enable NetworkManager
systemctl enable systemd-timesyncd
pacman -S --noconfirm podman fuse-overlayfs

# Set up users
useradd -m -G wheel -s /bin/bash $USER
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
echo "source /etc/profile.d/trueline.sh" >> /home/$USER/.bashrc

echo "$USER:$PW" | chpasswd
pacman -S --noconfirm \
    btrfs-progs squashfs-tools cargo rust \
    baobab gdm gnome-backgrounds gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-color-manager gnome-connections gnome-console gnome-control-center gnome-disk-utility gnome-font-viewer gnome-keyring gnome-logs gnome-remote-desktop gnome-session gnome-settings-daemon gnome-shell gnome-shell-extensions gnome-text-editor gnome-user-docs gnome-user-share gnome-weather gvfs gvfs-google loupe nautilus snapshot sushi xdg-desktop-portal-gnome totem \
    firefox discord steam noto-fonts nvidia-utils lib32-nvidia-utils pika-backup ttf-firacode-nerd mission-center krita obsidian
systemctl enable gdm

# Gnome extensions
mkdir -p /etc/dconf/profile
mkdir -p /etc/dconf/db/local.d

cat <<EOF > /etc/dconf/profile/user
user-db:user
system-db:local
EOF

dconf update

mkdir -p /root/extensions
cd /root/extensions
wget -c https://extensions.gnome.org/extension-data/blur-my-shellaunetx.v67.shell-extension.zip
wget -c https://extensions.gnome.org/extension-data/color-pickertuberry.v45.shell-extension.zip
wget -c https://extensions.gnome.org/extension-data/caffeinepatapon.info.v55.shell-extension.zip
gnome-extensions install blur-my-shellaunetx.v67.shell-extension.zip
gnome-extensions install color-pickertuberry.v45.shell-extension.zip
gnome-extensions install caffeinepatapon.info.v55.shell-extension.zip

chmod -R 755 /root/.local/share/gnome-shell/extensions/*
chown -R root:root /root/.local/share/gnome-shell/extensions/*
mv /root/.local/share/gnome-shell/extensions/* /usr/share/gnome-shell/extensions
rm -r /root/extensions

# System links
ls /home/$USER
ln -s /home/$USER/Data/Documents /home/$USER/Documents
ln -s /home/$USER/Data/Games /home/$USER/Games
ln -s /home/$USER/Data/Music /home/$USER/Music
ln -s /home/$USER/Data/Scripts /home/$USER/Scripts
ln -s /home/$USER/Data/Pictures /home/$USER/Pictures
ln -s /home/$USER/Data/Videos /home/$USER/Videos

mkdir -p /home/$USER/.config/StardewValley
ln -s /home/$USER/Games/Stardew\ Valley /home/$USER/.config/StardewValley/Saves
mkdir -p /home/$USER/.config/unity3d/Klei
ln -s /home/$USER/Games/Oxygen\ Not\ Included /home/$USER/.config/unity3d/Klei/OxygenNotIncluded
mkdir -p /home/$USER/.config/unity3d/Team\ Cherry
ln -s /home/$USER/Games/Hollow\ Knight /home/$USER/.config/unity3d/Team\ Cherry/Hollow\ Knight
mkdir -p /home/$USER/.local/share
ln -s /home/$USER/Games/Terraria /home/$USER/.local/share/Terraria
mkdir -p /home/$USER
ln -s /home/$USER/Games/Factorio /home/$USER/.factorio
mkdir -p /home/$USER/.local/share/Steam/steamapps/common/Cuphead
ln -s /home/$USER/Games/Cuphead /home/$USER/.local/share/Steam/steamapps/common/Cuphead/Saves
