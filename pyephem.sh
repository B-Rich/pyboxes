#!/bin/bash

# Once knit together a bit better, the steps in this shell script will
# be able to create a fresh machine image, install Arch Linux on it, and
# then set the resulting box up as an iPython Notebook server that
# anyone can use who wants to try out Python and astronomy.

set -e

vm () {
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
        -i sshkey -p 2022 root@127.0.0.1 "$@"
}

vboxmanage createvm --name "PyEphem" --ostype "ArchLinux" --register
vboxmanage modifyvm "PyEphem" \
    --bioslogodisplaytime 0 \
    --bioslogofadein off \
    --bioslogofadeout off \
    --memory 512 \
    --rtcuseutc on

DISK="PyEphem.vdi"

vboxmanage createhd --filename $DISK --size 1048576
vboxmanage storagectl "PyEphem" --name "SATA" --add sata --controller IntelAhci
vboxmanage storageattach "PyEphem" --storagectl "SATA" --port 0 --device 0 \
    --type hdd --medium $DISK

ISO=~/iso/archlinux-2012.12.01-dual.iso

vboxmanage storagectl "PyEphem" --name "IDE" --add ide --controller PIIX4
vboxmanage storageattach "PyEphem" --storagectl "IDE" --port 1 --device 0 \
    --type dvddrive --medium $ISO

vboxmanage modifyvm "PyEphem" --natpf1 ssh,tcp,,2022,,22
vboxmanage modifyvm "PyEphem" --natpf1 ipython,tcp,,8888,,8888

vboxmanage startvm "PyEphem" --type sdl

ssh-keygen -q -t rsa -N '' -f sshkey

cat <<EOF

1. Run Arch Linux from the mounted CD image
2. Run 'nc -l -p 1234 | bash' at the Arch Linux root command prompt
3. Then, press Enter here

EOF
read

cat <<EOF | nc 127.0.0.1 1234

systemctl start sshd
mkdir -p /root/.ssh
cat > /root/.ssh/authorized_keys <<EOT
$(cat sshkey.pub)
EOT
chmod og-rwx /root/.ssh /root/.ssh/*

EOF

# TODO: unmount CD when done

(echo n; echo p; echo 1; echo; echo; echo w) | vm fdisk /dev/sda
vm mkfs.ext4 /dev/sda1

vm mount /dev/sda1 /mnt

vm pacstrap /mnt base base-devel grub-bios
vm genfstab -p /mnt \>\> /mnt/etc/fstab
vm echo ephembox \> /mnt/etc/hostname
vm arch-chroot /mnt ln -s /usr/share/zoneinfo/US/Eastern /etc/localtime
vm arch-chroot /mnt mkinitcpio -p linux
vm arch-chroot /mnt grub-install /dev/sda
vm arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

vm arch-chroot /mnt pacman -S --noconfirm \
    openssh python2-matplotlib python2-scipy python2-virtualenv

vm arch-chroot /mnt systemctl enable sshd
vm arch-chroot /mnt systemctl enable dhcpcd
vm cp -rp /root/.ssh /mnt/root/.ssh

# Now that networking and SSH are provisioned, we can safely reboot.

# And then:

vm arch-chroot /mnt useradd -m john

vm dd of=/tmp/setup-john.sh <<-EOF
	set -e
	cd /home/john
	virtualenv2 --system-site-packages main
	source main/bin/activate
	pip install nose

	pip install ipython
	pip install pygments
	pip install pyzmq
	pip install tornado

	pip install pyephem
EOF

vm su john \< /tmp/setup-john.sh

vm dd of=/usr/lib/systemd/system/ipython.service <<-EOF
	[Unit]
	Description=iPython Notebook
	Requires=dhcpcd.service
	After=dhcpcd.service

	[Service]
	ExecStart=/home/john/main/bin/ipython notebook --ip=0.0.0.0
	KillMode=process

	[Install]
	WantedBy=multi-user.target
EOF

vm systemctl enable ipython
vm systemctl start ipython
