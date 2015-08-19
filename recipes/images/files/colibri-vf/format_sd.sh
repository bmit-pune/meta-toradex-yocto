#! /bin/sh
# Format a SD card to be used for flashing a Colibri VFxx module
# Then calls update.sh to add needed files

# sometimes we need the binary echo, not the shell builtin
ECHO=`which echo`

Usage()
{
	echo ""
	echo "Formats and fills a SD card with files for flashing the internal NAND of a"
	echo "Colibri VFxx. Optionally creates a rootfs partition to allow booting and taking"
	echo "kernel and rootfs from SD card."
	echo "ALL DATA ON THE DEVICE GIVEN WITH -d WILL BE DELETED!!"
	echo
	echo "Requires a running U-Boot on the target. Either one already flashed on the NAND"
	echo "or strapping the board to boot from SD card and booting U-Boot from the card"
	echo "(only possible on older samples without blown boot fuses)."
	echo ""
	echo "-h : Prints this message"
	echo ""
	echo "-d FILE : device file of the SD card"
	echo "-f      : additionally copy the rootfs into the second partition"
	echo "-s      : optimise file system for 128MB NAND, increases usable space"
	echo "          on VF50 module a little, but on VF61 uses also only 128MB"
	echo ""
	echo "Example \"./format_sd.sh -d /dev/mmcblk0\" prepares the SD card /dev/mmcblk0"
	echo ""
}

#initialise options
DEV="/dev/null"
CFGBLOCK_ONLY=0
DEBUG_ONLY=0
KERNEL_ONLY=0
UBOOT_ONLY=0
CP_ROOTFS=0

while getopts "hd:fs" Option ; do
	case $Option in
		h) 	Usage
			# Exit if only usage (-h) was specified.
			if [[ $# -eq 1 ]] ; then
				exit 10
			fi
			exit 0
			;;
		d) 	DEV=$OPTARG
			;;
		f)	CP_ROOTFS=1
			;;
		s)	UPDATE_OPTS="-s"
	esac
done

DEVNAME=`basename $DEV`
DEVNAMESTART=`echo $DEVNAME | cut -c 1-3`

# sanity checks to try and not touch one of the users hard drives or other issues
if [ ! -b $DEV ] ; then
	echo $DEV "is not a block device, "
	echo "please specify the device file representing your SD card"
	exit 1
fi
if [ "$DEVNAMESTART" = "sda"  ] ; then
	echo $DEV "seems to be your primary hard disk,"
	echo "please specify the device file representing your SD card"
	exit 1
fi
if [ ! -d /sys/block/$DEVNAME  ] ; then
	echo "/sys/block/$DEVNAME"
	echo $DEV "seems to not be a disk, please specify the device file"
	echo "representing your SD card (without any trailing number)"
	exit 1
fi
IS_USB_MMC=`ls -l /sys/block/$DEVNAME | grep -c "usb\|mmc"`
if [ $IS_USB_MMC -eq 0  ] ; then
	echo $DEV "seems not to be connected over USB or MMC, please specify the device file"
	echo "representing your SD card (without any trailing number)"
	exit 1
fi

if [ "$DEVNAMESTART" = "mmc"  ] ; then
        PART_PREFIX="p"
else
        PART_PREFIX=""
fi
# make sure the partitions are unmounted
sudo umount ${DEV}${PART_PREFIX}?

# partition and format the vfat partition
sudo parted -s $DEV   mklabel msdos   mkpart primary fat32 1MB 512MB   mkpart primary ext3 512MB 100%
sudo umount ${DEV}${PART_PREFIX}1
sudo mkfs.vfat -n UPDATE ${DEV}${PART_PREFIX}1

# dd U-Boot onto the SD card
sudo dd if=colibri-vf_bin/u-boot.imx of=${DEV} bs=512 seek=2

sudo mkdir -p mntpoint1
sudo mount -t vfat ${DEV}${PART_PREFIX}1 mntpoint1 -o umask=0

# now copy U-Boot, kernel and ubi-img to the KERNEL partition
DEST=`readlink -e mntpoint1`
./update.sh -o "$DEST" $UPDATE_OPTS

#copy the rootfs
if [ "$CP_ROOTFS" -eq 1 ] ; then
	sudo umount ${DEV}${PART_PREFIX}2
	sudo mkfs.ext3 -L RFS ${DEV}${PART_PREFIX}2 && sync
	sudo mkdir -p mntpoint2
	sudo mount -t ext3 ${DEV}${PART_PREFIX}2 mntpoint2
	sudo cp -pPr rootfs/* mntpoint2/
fi

sudo umount ${DEV}${PART_PREFIX}?
