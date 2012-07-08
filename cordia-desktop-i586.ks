lang en_US.UTF-8
keyboard us
timezone --utc America/Los_Angeles
part / --size 3000 --ondisk sda --fstype=ext3
rootpw cordia
xconfig --startxonboot
bootloader  --timeout=0  --append="quiet" 
user --name cordia --groups audio,video,wheel --password cordia

repo --name=mer-core --baseurl=http://releases.merproject.org/releases/latest/builds/i586/packages/ --save --debuginfo
repo --name=cordia-desktop --baseurl=http://repo.pub.meego.com//Project:/Cordia:/Desktop/Mer_Core_i586/ --save
repo --name=cordia-apps --baseurl=http://repo.pub.meego.com//Project:/Cordia:/Apps/Mer_Core_i586/ --save
repo --name=cordia-tools --baseurl=http://repo.pub.meego.com//Project:/Cordia:/Tools/Mer_Core_i586/ --save
repo --name=mer-tools --baseurl=http://repo.pub.meego.com/Mer:/Tools/Mer_next_Core_i586/ --save --debuginfo --source
repo --name=ce-adaptation-x86-generic --baseurl=http://repo.pub.meego.com/CE:/Adaptation:/x86-generic/Mer_Core_i586/ --save

%packages

@Mer Core
@Mer Graphics Common
@Mer Connectivity
@Intel x86 Generic Support
@Mer Minimal Xorg

kernel-adaptation-pc

openssh-clients
openssh-server
xterm
vim-enhanced

connman-test

# SDK
build
mer-kickstarter
mic
mpc
net-tools
osc
psmisc
spectacle
sudo

# Desktop
mutter

%end

%post
# work around for poor key import UI in PackageKit
rm -f /var/lib/rpm/__db*
rpm --rebuilddb

# Prelink can reduce boot time
if [ -x /usr/sbin/prelink ]; then
    /usr/sbin/prelink -aRqm
fi

# Set symlink pointing to .desktop file 
ln -sf /usr/share/gnome/wm-properties/mutter-wm.desktop /usr/share/xsessions/default.desktop

# Disable pam_systemd as it breaks sudo
# See MER#379 https://bugs.merproject.org/show_bug.cgi?id=379
sed -i '/pam_systemd.so/s/^/#/' /etc/pam.d/system-auth

# Disable SSH "GSSAPIAuthentication"
sed -i '/GSSAPIAuthentication/s/^/#/' /etc/ssh/ssh_config

%end

%post --nochroot
if [ -n "$IMG_NAME" ]; then
    echo "BUILD: $IMG_NAME" >> $INSTALL_ROOT/etc/meego-release
fi


%end
