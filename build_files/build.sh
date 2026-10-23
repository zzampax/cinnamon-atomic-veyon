#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# Utility packages
dnf5 install -y tmux nmap libreoffice

# Cinnamon Desktop Environment + Correlated misc
dnf5 install -y cinnamon \
                cinnamon-session \
                cinnamon-desktop \
                cinnamon-control-center \
                cinnamon-screensaver \
                cinnamon-translations \
                cinnamon-settings-daemon \
                cinnamon-themes \
                yaru-icon-theme \
                nemo \
                nemo-extensions \
                xapps \
                lightdm \

# Create lightdm data directory with proper permissions
RUN mkdir -p /var/lib/lightdm-data && \
    chown -R lightdm:lightdm /var/lib/lightdm-data && \
    chmod 0700 /var/lib/lightdm-data

# Browser and Terminal
dnf5 install -y firefox gnome-console

# Veyon configuration
wget -O /tmp/veyon.rpm https://github.com/veyon/veyon/releases/download/v4.11.3/veyon-4.11.3.0-fedora.44.x86_64.rpm
dnf5 reinstall -y procps-ng
dnf5 install -y /tmp/veyon.rpm

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
systemctl disable brltty.service
