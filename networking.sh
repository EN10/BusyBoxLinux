# create busybox initramfs
sudo apt update
sudo apt install git make gcc ncurses-dev bzip2
git clone --depth 1 https://git.busybox.net/busybox
# git pull --depth 1
cd busybox
make menuconfig
# Settings - Build static binary
# https://github.com/EN10/BusyBoxLinux/blob/main/lib/BusyBox-static.sh
make -j 8
make CONFIG_PREFIX=../initramfs install

# glibc libraries for DNS
# https://wiki.gentoo.org/wiki/Custom_Initramfs#DNS
# https://github.com/EN10/BusyBoxLinux/blob/main/lib/lib-files.sh
cd ../initramfs
# copy DNS libraries from host
mkdir -p lib/x86_64-linux-gnu
cp /lib/x86_64-linux-gnu/libnss_{dns,files}.so.2 /lib/x86_64-linux-gnu/{libresolv,ld-linux-x86-64}.so.2 /lib/x86_64-linux-gnu/libc.so.6 lib/x86_64-linux-gnu
# OR use APT: https://github.com/EN10/BusyBoxLinux/blob/main/lib/libc6-apt-dns.sh

# setup /etc
cd ../../initramfs
mkdir etc && cd etc
# services from https://www.linuxfromscratch.org/lfs/view/stable/chapter08/iana-etc.html
wget https://raw.githubusercontent.com/EN10/BusyBoxLinux/main/etc/services
echo 'nameserver 8.8.8.8' > resolv.conf

cd ../initramfs
# /init & /sbin/ethernet based on https://github.com/maksimKorzh/msmd-linux/releases/download/0.1/root.zip
wget https://raw.githubusercontent.com/EN10/BusyBoxLinux/main/bootfiles/init
chmod +x init
rm linuxrc

# create init.cpio.gz
cd ../initramfs
find . | cpio -o -H newc | gzip -9 > ../init.cpio.gz
