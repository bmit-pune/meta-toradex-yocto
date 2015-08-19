# meta-toradex-yocto
#////////////////////////////////////////////////////////////////////////////////////////
#Bitmapper Integration ///
#Maintaner:Piyush Ashtikar [piyushashtikar@outlook.com,piyush.ashtikar@bitmapper.com] ///
#////////////////////////////////////////////////////////////////////////////////////////
This is unofficial bsp layer for toradex to support apalis imx6 daughter board on yocto poky framework.
Using this bsp you can build the linux-imx for apalis.
Rootfs images such as core-image-minimal(tested) and all other multimedia images(not-tested) can be used.
Steps involved are:
1:)in local.conf set machine to apalis-imx6
2:)In sources directory git clone this folder meta-toradex-yocto
3:)in bblayers.conf add meta-toradex-yocto.
4:)bitbake core-image-minimal
5:)Prepare sd card
1st partition:1gb:fat16
2nd partition:rest space in card:ext3
6:)
mount /dev/[first partition] /mnt/mountpoint
from deploy folder
cp uImage-imx6q-apalis-eval.dtb /mnt/mountpoint/
cp uImage-imx6q-apalis-eval_v1_0.dtb /mnt/mountpoint/
cp uImage /mnt/mountpoint/
7:)tar the rootfs from deploy folder
mount /dev/[second partition] /mnt/mountpoint
cp -pPrv rootfs_folder/* /mnt/mountpoint
8:)stop the boot process
Now you need to set boot parameters
in sdargs change rootfs to mmcblk0p2(ie sdcard partition 2)
9:)run sdboot
Now core Image minimal should start.
Done :)
Fell free to ask any queries
piyushashtikar@outlook.com
piyush.ashtikar@bitmapper.com

