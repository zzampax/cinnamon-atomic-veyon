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
wget -O /tmp/veyon.rpm https://github.com/veyon/veyon/releases/download/v4.11.4/veyon-4.11.4.0-fedora.44.x86_64.rpm
dnf5 reinstall -y procps-ng
dnf5 install -y /tmp/veyon.rpm

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

# Setup Automatic Updates service
# Create the service file
cat > /etc/systemd/system/bootc-upgrade.service << 'EOF'
[Unit]
Description=bootc upgrade
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/bootc upgrade
StandardOutput=journal
StandardError=journal
EOF

# Create the timer file
cat > /etc/systemd/system/bootc-upgrade.timer << 'EOF'
[Unit]
Description=Daily bootc upgrade at 04:00 AM
Requires=bootc-upgrade.service

[Timer]
OnCalendar=daily
OnCalendar=*-*-* 04:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Enable needed services
systemctl enable bootc-upgrade.timer
systemctl enable podman.socket

# Disable unwanted services
systemctl disable brltty.service
systemctl disable sshd.service
# Replace following with firewall-cmd <enable veyon ports>
systemctl disable firewalld.service
