# -*-mic2-options-*- -f raw --copy-kernel --record-pkgs=name --pkgmgr=yum --arch=armv7hl -*-mic2-options-*-
# 
# Do not Edit! Generated by:
# kickstarter.py
# 

lang en_US.UTF-8
keyboard us
timezone --utc Europe/Helsinki
part / --size=3600  --ondisk mmcblk0p --fstype=ext4

# This is not used currently. It is here because the /boot partition
# needs to be the partition number 3 for the u-boot usage.
part swap --size=8 --ondisk mmcblk0p --fstype=swap

# This partition is made so that u-boot can find the kernel
part /boot --size=32 --ondisk mmcblk0p --fstype=vfat

rootpw cordia 

user --name cordia  --groups audio,video --password cordia 

repo --name=mer-core --baseurl=http://releases.merproject.org/releases/latest/builds/armv7hl/packages/ --save --debuginfo
repo --name=cordia-hildon --baseurl=http://repo.pub.meego.com/Project:/Cordia:/Hildon/Mer_Core_armv7hl/ --save
repo --name=ce-adaptation-n9xx-common --baseurl=http://repo.pub.meego.com/CE:/Adaptation:/N9xx-common/Mer_Core_armv7hl/ --save
repo --name=ce-adaptation-n900 --baseurl=http://repo.pub.meego.com/CE:/Adaptation:/N900/CE_Adaptation_N9xx-common_armv7hl/ --save

%packages

@Mer Core
@Mer Graphics Common
@Mer Connectivity
@Nokia N900 Support
@Nokia N900 Proprietary Support

kernel-adaptation-n900

openssh-clients
openssh-server
vim-enhanced
xorg-x11-xauth

# Cordia HD
sound-theme-freedesktop
gnome-mime-data
gtk2-engines-sapwood
hildon-desktop
hildon-home
hildon-status-menu
hildon-theme-cacher
hildon-theme-layout-5
libhildon
libhildondesktop
libosso
osso-af-settings
hildon-theme-marina

%end

%post
# work around for poor key import UI in PackageKit
rm -f /var/lib/rpm/__db*
rpm --rebuilddb

# Prelink can reduce boot time
if [ -x /usr/sbin/prelink ]; then
    /usr/sbin/prelink -aRqm
fi


# Hack to fix the plymouth based splash screen on N900
mv /usr/bin/ply-image /usr/bin/ply-image-real
cat > /usr/bin/ply-image << EOF
#!/bin/sh
echo 32 > /sys/class/graphics/fb0/bits_per_pixel
exec /usr/bin/ply-image-real $@
EOF
chmod +x /usr/bin/ply-image

# Use eMMC swap partition as MeeGo swap as well.
# Because of the 2nd partition is swap for the partition numbering
# we can just change the current fstab entry to match the eMMC partition.
sed -i 's/mmcblk0p2/mmcblk1p3/g' /etc/fstab

# This causes problems with the bme in N900 images so removing for now.
rm -f /lib/modules/*/kernel/drivers/power/bq27x00_battery.ko
# Remove cursor from showing during startup BMC#14991
echo "xopts=-nocursor" >> /etc/sysconfig/uxlaunch

# Without this line the rpm don't get the architecture right.
echo -n 'armv7hl-meego-linux' > /etc/rpm/platform
 
# Also libzypp has problems in autodetecting the architecture so we force tha as well.
# https://bugs.meego.com/show_bug.cgi?id=11484
echo 'arch = armv7hl' >> /etc/zypp/zypp.conf

# Set marina theme as default
ln -s marina /usr/share/themes/default

# Set symlink pointing to .desktop file
ln -sf x-hildon.desktop /usr/share/xsessions/default.desktop
# and services
ln -sf ../hildon-home.service ../hildon-status-menu.service /lib/systemd/system/graphical.target.wants/

%end

%post --nochroot
if [ -n "$IMG_NAME" ]; then
    echo "BUILD: $IMG_NAME" >> $INSTALL_ROOT/etc/mer-release
fi


%end
