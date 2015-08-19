#!/bin/sh
# Prepare files needed for flashing an Apalis/Colibri T20/T30 module and
# copy them to a convenient location for using from a running U-Boot

# sometimes we need the binary echo, not the shell builtin
ECHO=`which echo`
#some distros have fs tools only in root's path
PARTED=`which parted` 2> /dev/null
if [ -e "$PARTED" ] ; then
	MKFSVFAT=`which mkfs.vfat`
else
	PARTED=`sudo which parted`
	MKFSVFAT=`sudo which mkfs.vfat`
fi

Flash()
{
	echo ""
	echo "To flash the Apalis/Colibri T20/T30 module, boot the module to the U-Boot prompt"
	echo "and"
	echo ""
	echo "when using a SD card, insert the SD card and enter:"
	echo "run setupdate"
	echo ""
	echo "when using tftp, connect Ethernet and enter:"
	echo "tftp \$loadaddr flash_eth.img ; source \$loadaddr"
	echo ""
	echo "then enter to update all:"
	echo "run update"
	echo ""
	echo "to update a single component enter one of:"
	echo "run update_uboot"
	echo "run update_kernel"
	echo ""
	echo ""
	echo "If you don't have a working U-Boot anymore, connect your PC to the module's USB"
	echo "client port, bring the module into the recovery mode and start the update.sh"
	echo "script with the -d option. This will copy U-Boot into the module's RAM and"
	echo "execute it."
}

Usage()
{
	echo ""
	echo "Prepares and copies files for flashing the internal eMMC/NAND of an Apalis/"
	echo "Colibri T20/T30"
	echo ""
	echo "Will require a running U-Boot on the target. Either one already flashed"
	echo "on the eMMC/NAND or one copied over USB into the module's RAM"
	echo ""
	echo "-b           : T20: selects boot device (hsmmc/nand) (default: nand)"
	echo "-d           : use USB recovery mode to copy/execute U-Boot to the module's RAM"
	echo "-f           : flash instructions"
	echo "-h           : prints this message"
	echo "-o directory : output directory, if this is on a SD card, it should be the first"
	echo "               partition formated with VFAT"
	echo "-r           : T20 recovery mode: select RAM size (256 | 512)"
	echo "-s           : optimise file system for V1.1 or 256MB V1.2 modules, increases"
	echo "               usable space a little, but limits 512MB V1.2 modules to 512MB"
	echo "               usable NAND space"
	echo "-v           : T20 recovery mode: select Colibri version (V1_1 | V1_2)"
	echo ""
	echo "Example \"./update.sh -o /run/media/user/label\" copies files to SD card"
	echo "Example \"./update.sh -o /srv/tftp/\" copies the requiered files to /srv/tftp/"
	echo ""
	echo "*** For detailed recovery/update procedures, refer to the Release Notes ***"
	echo ""
}

# initialise options
BOOT_DEVICE=nand
EMMC_PARTS="mbr.bin boot.vfat" 
# no devicetree by default
KERNEL_DEVICETREE=""
KERNEL_IMAGETYPE="uImage"
MIN_PARTITION_FREE_SIZE=100

# NAND parameters
BLOCK="248KiB 504KiB"
MAXLEB=4084
PAGE="4KiB"

OUT_DIR=""
ROOTFSPATH=rootfs
UBOOT_RECOVERY=0

# don't provide working defaults which may lead to wrong HW/SW combination
MODVERSION=Add_Version_-v
RAM_SIZE=Add_RAMsize_-r

while getopts "b:dfho:r:sv:" Option ; do
	case $Option in
		b)	BOOT_DEVICE=$OPTARG
			;;
		d)	UBOOT_RECOVERY=1
			;;
		f)	Flash
			exit 0
			;;
		h)	Usage
			# Exit if only usage (-h) was specified.
			if [ "$#" -eq 1 ] ; then
				exit 10
			fi
			exit 0
			;;
		o)	OUT_DIR=$OPTARG
			;;
		r)	RAM_SIZE=$OPTARG
			;;
		s)	MAXLEB=2042
			;;
		v)	if [ "${OPTARG}" = "V1_1" ] ; then MODVERSION=v11; fi
			if [ "${OPTARG}" = "V1_2" ] ; then MODVERSION=v12; fi
			;;
	esac
done

if [ "$OUT_DIR" = "" ] && [ "$UBOOT_RECOVERY" = "0" ] ; then
	Usage
	exit 0
fi

# auto detect MODTYPE from rootfs directory
CNT=`grep -ic "apalis" rootfs/etc/issue || true`
if [ "$CNT" -ge 1 ] ; then
	CNT=`grep -ic "t30" rootfs/etc/issue || true`
	if [ "$CNT" -ge 1 ] ; then
		echo "Apalis T30 rootfs detected"
		MODTYPE=apalis-t30
		IMAGEFILE=root.ext3
		U_BOOT_BINARY=u-boot-dtb-tegra.bin
		KERNEL_DEVICETREE="tegra30-apalis-eval.dtb"
		LOCPATH="tegra-uboot-flasher"
		# eMMC size [in sectors of 512]
		EMMC_SIZE=$(expr 1024 \* 7450 \* 2)
		BCT=apalis_t30_12MHz_MT41K512M8RH-125_533MHz.bct
		CBOOT_IMAGE=apalis_t30.img
		CBOOT_IMAGE_TARGET=tegra30
	else
		echo "can not detect module type from ./rootfs/etc/issue"
		echo "exiting"
		exit 1
	fi
else
	CNT=`grep -ic "colibri" rootfs/etc/issue || true`
	if [ "$CNT" -ge 1 ] ; then
		CNT=`grep -ic "t20" rootfs/etc/issue || true`
		if [ "$CNT" -ge 1 ] ; then
			echo "Colibri T20 rootfs detected"
			MODTYPE=colibri-t20
			IMAGEFILE=ubifs
			U_BOOT_BINARY=u-boot-dtb-tegra.bin
			KERNEL_DEVICETREE="tegra20-colibri-eval-v3.dtb"
			LOCPATH="tegra-uboot-flasher"
			BCT=colibri_t20-${RAM_SIZE}-${MODVERSION}-${BOOT_DEVICE}.bct
			CBOOT_IMAGE="colibri_t20-256-v11-nand.img colibri_t20-256-v12-nand.img colibri_t20-512-v11-nand.img colibri_t20-512-v12-nand.img"
			CBOOT_IMAGE_TARGET=tegra20
			# zImage but from rootfs/boot
			KERNEL_IMAGETYPE=""
			EMMC_PARTS=""
		else
			CNT=`grep -ic "t30" rootfs/etc/issue || true`
			if [ "$CNT" -ge 1 ] ; then
				echo "Colibri T30 rootfs detected"
				MODTYPE=colibri-t30
				IMAGEFILE=root.ext3
				U_BOOT_BINARY=u-boot-dtb-tegra.bin
				KERNEL_DEVICETREE="tegra30-colibri-eval-v3.dtb"
				LOCPATH="tegra-uboot-flasher"
				EMMC_SIZE=$(expr 1024 \* 2000 \* 2)
				# with new kernel, boot with 400MHz, then switch between 400 & 800
				BCT=colibri_t30_12MHz_NT5CC256M16CP-DI_400MHz.bct
#				BCT=colibri_t30_12MHz_NT5CC256M16CP-DI_533MHz.bct
				CBOOT_IMAGE=colibri_t30.img
				CBOOT_IMAGE_TARGET=tegra30
			else
				echo "can not detect module type from ./rootfs/etc/issue"
				echo "exiting"
				exit 1
			fi
		fi
	else
		echo "can not detect module type from ./rootfs/etc/issue"
		echo "exiting"
		exit 1
	fi
fi
BINARIES=${MODTYPE}_bin

#is only U-Boot to be copied to RAM?
if [ "$UBOOT_RECOVERY" -eq 1 ] ; then
	if [ "${MODTYPE}" = "colibri-t20" ] ; then
		#some sanity test, we really need RAM_SIZE and MODVERSION set
		echo ""
		echo "256, 512" | grep -q ${RAM_SIZE}
		if [ $? -eq 1 ] ; then
			$ECHO -e "\033[1mplease specify your RAM size with the -r parameter\033[0m"
		fi

		echo "v11, v12" | grep -q ${MODVERSION}
		if [ $? -eq 1 ] ; then
			$ECHO -e "\033[1mplease specify your module version with the -v parameter\033[0m"
			Usage
			exit 0
		fi

		echo "256, 512" | grep -q ${RAM_SIZE}
		if [ $? -eq 1 ] ; then
			Usage
			exit 0
		fi
	fi

	cd ${LOCPATH}
	sudo ./tegrarcm --bct=../${BINARIES}/${BCT} --bootloader=../${BINARIES}/${U_BOOT_BINARY} --loadaddr=0x80108000
	exit 1
fi

# is OUT_DIR an existing directory?
if [ ! -d "$OUT_DIR" ] ; then
	echo "$OUT_DIR" "does not exist, exiting"
	exit 1
fi

#sanity check for correct untared rootfs
DEV_OWNER=`ls -ld rootfs/dev | awk '{print $3}'`
if [ "${DEV_OWNER}x" != "rootx" ]
then
	$ECHO -e "rootfs/dev is not owned by root, but it should!"
	$ECHO -e "\033[1mPlease unpack the tarball with root rights.\033[0m"
	$ECHO -e "e.g. sudo tar xjvf Apalis_T30_LinuxImageV2.3Beta5_20141219.tar.bz2"
	exit 1
fi

#sanity check for existence of U-Boot and kernel
[ -e ${BINARIES}/${U_BOOT_BINARY} ] || { echo "${BINARIES}/${U_BOOT_BINARY} does not exist"; exit 1; }
[ -e ${BINARIES}/${KERNEL_IMAGETYPE} ] || { echo "${BINARIES}/${KERNEL_IMAGETYPE} does not exist"; exit 1; }

#sanity check for some programs
MCOPY=`sudo which mcopy`
[ "${MCOPY}x" != "x" ] || { echo >&2 "Program mcopy not available.  Aborting."; exit 1; }
sudo ${PARTED} -v >/dev/null 2>&1 || { echo >&2 "Program parted not available.  Aborting."; exit 1; }
[ "${MKFSVFAT}x" != "x" ] || { echo >&2 "Program mkfs.vfat not available.  Aborting."; exit 1; }
MKFSEXT3=`sudo which mkfs.ext3`
[ "${MKFSEXT3}x" != "x" ] || { echo >&2 "Program mkfs.ext3 not available.  Aborting."; exit 1; }
awk -V  >/dev/null 2>&1 || { echo >&2 "Program awk not available.  Aborting."; exit 1; }
dd --help >/dev/null 2>&1 || { echo >&2 "Program dd not available.  Aborting."; exit 1; }
tegra-uboot-flasher/cbootimage -h >/dev/null 2>&1
[ "$?" -lt 2 ] || { echo >&2 "Program cbootimage not available. 32bit compatibility libs?  Aborting."; exit 1; }

if [ "${MODTYPE}" = "colibri-t20" ] ; then
	#sanity check, can we execute mkfs.ubifs, e.g. see the help text?
	CNT=`sudo $LOCPATH/mkfs.ubifs -h | grep -c space-fixup`  
	if [ "$CNT" -eq 0 ] ; then
		echo "The program mkfs.ubifs can not be executed or does not provide --space-fixup"
		echo "option."
		echo "Are you on a 64-bit Linux host without installed 32-bit execution environment?"
		$ECHO -e  "\033[1mPlease install e.g. ia32-libs on 64-bit Ubuntu\033[0m"
		$ECHO -e  "\033[1mMaybe others are needed e.g. liblzo2:i386 on 64-bit Ubuntu\033[0m"
		exit 1
	fi
fi

#make the directory with the outputfiles writable
sudo chown $USER: ${BINARIES}

#make a file with the used versions for U-Boot, kernel and rootfs
sudo touch ${BINARIES}/versions.txt
sudo chmod ugo+w ${BINARIES}/versions.txt
echo "Component Versions" > ${BINARIES}/versions.txt
basename "`readlink -e ${BINARIES}/${U_BOOT_BINARY}`" >> ${BINARIES}/versions.txt
if [ "${MODTYPE}" = "colibri-t20" ] ; then
	basename "`readlink -m rootfs/boot/zImage`" >> ${BINARIES}/versions.txt
else
	basename "`readlink -e ${BINARIES}/${KERNEL_IMAGETYPE}`" >> ${BINARIES}/versions.txt
fi
$ECHO -n "Rootfs " >> ${BINARIES}/versions.txt
grep -i t[2-3]0 rootfs/etc/issue >> ${BINARIES}/versions.txt

# The emmc layout used is:
#
# boot area partition 1 aka eMMC boot sector:
#
# with cbootimage containing BCT and U-Boot boot loader
#
# user area aka general purpose eMMC region:
#
#    0                      -> IMAGE_ROOTFS_ALIGNMENT         - reserved to bootloader (not partitioned)
#    IMAGE_ROOTFS_ALIGNMENT -> BOOT_SPACE                     - kernel and other data
#    BOOT_SPACE             -> SDIMG_SIZE                     - rootfs
#
#                                                     Default Free space = 1.3x
#                                                     Use IMAGE_OVERHEAD_FACTOR to add more space
#                                                     <--------->
#            4MiB               16MiB           SDIMG_ROOTFS                    4MiB
# <-----------------------> <----------> <----------------------> <------------------------------>
#  ------------------------ ------------ ------------------------ -------------------------------
# | IMAGE_ROOTFS_ALIGNMENT | BOOT_SPACE | ROOTFS_SIZE            |     IMAGE_ROOTFS_ALIGNMENT    |
#  ------------------------ ------------ ------------------------ -------------------------------
# ^                        ^            ^                        ^                               ^
# |                        |            |                        |                               |
# 0                      4096     4MiB +  16MiB       4MiB +  16Mib + SDIMG_ROOTFS   4MiB +  16MiB + SDIMG_ROOTFS + 4MiB
#
# with the U-Boot environment at 512 * 1024, the config block is at 640 * 1024

# generate cbootimage(s) containing BCT(s) and U-Boot boot loader
cd ${BINARIES}
for cbootimage in ${CBOOT_IMAGE}; do
	sudo ../${LOCPATH}/cbootimage -s ${CBOOT_IMAGE_TARGET} ${cbootimage}.cfg ${cbootimage}
done
cd ..

if [ "${MODTYPE}" = "colibri-t20" ] ; then
	# Prepare full flashing
	#build ${IMAGEFILE} if it does not exist
	for blocksize in ${BLOCK}; do
		sudo $LOCPATH/mkfs.ubifs -c ${MAXLEB} -e ${blocksize} -m ${PAGE} -o ${BINARIES}/${IMAGEFILE}_${blocksize}.img -r rootfs/ -v
	done

	echo ""
	echo "UBI image of root file system generated, coping data to target folder..."
else
	if [ "${MODTYPE}" = "apalis-t30" ] || [ "${MODTYPE}" = "colibri-t30" ] ; then
		# Boot partition [in sectors of 512]
		BOOT_START=$(expr 4096 \* 2)
		# Rootfs partition [in sectors of 512]
		ROOTFS_START=$(expr 20480 \* 2)
		# Boot partition volume id
		BOOTDD_VOLUME_ID="boot"

		#make the partition size size(rootfs used + MIN_PARTITION_FREE_SIZE)
		#add about 4% to the rootfs to account for fs overhead. (/1024/985 instead of /1024/1024).                                                                                    
		#add 512 bytes per file to account for small files
		NUMBER_OF_FILES=`sudo find ${ROOTFSPATH} | wc -l`
		EXT_SIZE=`sudo du -DsB1 ${ROOTFSPATH} | awk -v min=$MIN_PARTITION_FREE_SIZE -v f=${NUMBER_OF_FILES} \
				'{rootfs_size=$1+f*512;rootfs_size=int(rootfs_size/1024/985); print (rootfs_size+min) }'`

		echo ""
		echo "Creating MBR file and do the partitioning"
		# Initialize a sparse file
		dd if=/dev/zero of=${BINARIES}/mbr.bin bs=512 count=0 seek=${EMMC_SIZE}
		${PARTED} -s ${BINARIES}/mbr.bin mklabel msdos
		${PARTED} -a none -s ${BINARIES}/mbr.bin unit s mkpart primary fat32 ${BOOT_START} $(expr ${ROOTFS_START} - 1 )
		# the partition spans to the end of the disk, even though the fs size will be smaller
		# on the target the fs is then grown to the full size
		${PARTED} -a none -s ${BINARIES}/mbr.bin unit s mkpart primary ext2 ${ROOTFS_START} $(expr ${EMMC_SIZE} \- ${ROOTFS_START} \- 1)
		${PARTED} -s ${BINARIES}/mbr.bin unit s print 
		# get the size of the VFAT partition
		BOOT_BLOCKS=$(LC_ALL=C ${PARTED} -s ${BINARIES}/mbr.bin unit b print \
			| awk '/ 1 / { print int(substr($4, 1, length($4 -1)) / 1024) }')
		# now crop the file to only the MBR size
		IMG_SIZE=512
		truncate -s $IMG_SIZE ${BINARIES}/mbr.bin


		echo ""
		echo "Creating VFAT partion image with the kernel"
		rm -f ${BINARIES}/boot.vfat
		${MKFSVFAT} -n "${BOOTDD_VOLUME_ID}" -S 512 -C ${BINARIES}/boot.vfat $BOOT_BLOCKS 
		export MTOOLS_SKIP_CHECK=1
		mcopy -i ${BINARIES}/boot.vfat -s ${BINARIES}/${KERNEL_IMAGETYPE} ::/${KERNEL_IMAGETYPE}

		# Copy device tree file
		COPIED=false
		if test -n "${KERNEL_DEVICETREE}"; then
			for DTS_FILE in ${KERNEL_DEVICETREE}; do
				DTS_BASE_NAME=`basename ${DTS_FILE} | awk -F "." '{print $1}'`
				if [ -e "${BINARIES}/${KERNEL_IMAGETYPE}-${DTS_BASE_NAME}.dtb" ]; then
					kernel_bin="`readlink ${BINARIES}/${KERNEL_IMAGETYPE}`"
					kernel_bin_for_dtb="`readlink ${BINARIES}/${KERNEL_IMAGETYPE}-${DTS_BASE_NAME}.dtb | sed "s,$DTS_BASE_NAME,${MODTYPE},g;s,\.dtb$,.bin,g"`"
					if [ "$kernel_bin" = "$kernel_bin_for_dtb" ]; then
						mcopy -i ${BINARIES}/boot.vfat -s ${BINARIES}/${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${DTS_BASE_NAME}.dtb ::/${DTS_BASE_NAME}.dtb
						#copy also to out_dir
						sudo cp ${BINARIES}/${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${DTS_BASE_NAME}.dtb "$OUT_DIR/${DTS_BASE_NAME}.dtb"
						COPIED=true
					fi
				fi
			done
		fi

		echo ""
		echo "Creating rootfs partion image"
		rm -f ${BINARIES}/${IMAGEFILE}
		sudo $LOCPATH/genext3fs.sh -d rootfs -b ${EXT_SIZE} ${BINARIES}/${IMAGEFILE} || exit 1
	fi
fi

#copy to $OUT_DIR
cd ${BINARIES}
sudo cp ${CBOOT_IMAGE} ${KERNEL_IMAGETYPE} ${EMMC_PARTS} ${IMAGEFILE}* flash*.img versions.txt "$OUT_DIR"
cd ..
sync
echo "Successfully copied data to target folder."
echo ""

Flash
