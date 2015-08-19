#! /bin/sh

Usage()
{
	echo "create_configblock creates a configblock binary from the info on the module sticker."
	echo "This can be used when the configblock got lost during a failed update attempt."
	echo ""
	echo "The created config-block will be copied to the choosen output directory when running"
	echo "the update.sh command."
	echo ""
	echo "In order to write the config block enter on the U-Boot commandline:"
	echo "run update"
	echo "run update_configblock"
	echo ""
	echo "For Colibri VF modules the boot configuration block needs to be recreated first:"
	echo "run update"
	echo "run create_bcb"
	echo "run update_configblock"
	echo ""
}

while getopts "h" Option ; do
        case $Option in
                h) Usage
                        # Exit if only usage (-h) was specfied.
                        if [[ $# -eq 1 ]] ; then
                                exit 10
                        fi
                        exit 0
                        ;;
        esac
done

# autotect MODTYPE from from rootfs directory
CNT=`grep -c "T20" rootfs/etc/issue || true`
if [ ${CNT} -ge 1 ] ; then
	echo "Colibri T20 rootfs detected"
	MODTYPE=colibri-t20
	BOOT_DEVICE=nand
else
	CNT=`grep -c "T30" rootfs/etc/issue || true`
	if [ ${CNT} -ge 1 ] ; then
		CNT=`grep -c "Apalis" rootfs/etc/issue || true`
		if [ ${CNT} -ge 1 ] ; then
			echo "Apalis T30 rootfs detected"
			MODTYPE=apalis-t30
		else
			echo "Colibri T30 rootfs detected"
			MODTYPE=colibri-t30
		fi
	else
		CNT=`grep -c "VF" rootfs/etc/issue || true`
		if [ "$CNT" -ge 1 ] ; then
			echo "Colibri VF rootfs detected"
			MODTYPE=colibri-vf
		else
			CNT=`grep -c "Colibri_iMX6" rootfs/etc/issue || true`
			if [ "$CNT" -ge 1 ] ; then
				echo "Colibri iMX6 rootfs detected"
				MODTYPE=colibri-imx6
			else
				CNT=`grep -ic "imx6" rootfs/etc/issue || true`
				if [ "$CNT" -ge 1 ] ; then
					echo "Apalis iMX6 rootfs detected"
					MODTYPE=apalis-imx6
				else
					echo "can not detect modulue type from ./rootfs/etc/issue"
					echo "exiting"
					exit 1
				fi
			fi
		fi
	fi
fi

echo "Enter the modules serial number on the modules sticker or"
echo "use a barcode scanner to enter the content of the stickers barcode"

# read a barcode and test it to be 8 or 16 numbers only 0025100102489109 0115100000000024
#                                                       1234567890123456 1234567890123456
until [ "${BARCODE}x" != "x" ]
do
	read BARCODE
	#remove all whitespace
	BARCODE=`echo $BARCODE | tr -d ' '`	
	#get strlen and the number of numeric characters
	STRLEN=`echo $BARCODE  | wc -c`
	NUMCNT=`echo $BARCODE | sed 's/[^0-9]//g' | wc -c`
	if [ $STRLEN -ne 17 ] ; then 
		if [ $STRLEN -ne 9 ] ; then
			echo "The serial number must be 8 numbers long (the barcode 16)"
			BARCODE=""
		fi
	fi
	if [ $NUMCNT -ne $STRLEN ] ; then
		echo "The serial number must contain all numeric characters"
		BARCODE=""
	fi
done
DATECODE=19700101000000
if [ $STRLEN -eq 17 ] ; then
	SERIALNR=`echo $BARCODE | awk 'BEGIN{ FIELDWIDTHS = "8 8"} {print $2}'`
	PRODUCTNR=`echo $BARCODE | awk 'BEGIN{ FIELDWIDTHS = "8 8"} {print $1}'`
else
	SERIALNR=$BARCODE
	case ${MODTYPE} in
	"apalis-imx6")
		RAM_SIZE=1024
		echo "Enter the RAM size ( 512 / 1024 / 2048 ):"
		read RAM_SIZE
		case ${RAM_SIZE} in
		"512")
			PROD_ID="0029"
			;;
		"1024") 
			PROD_ID="0027"
			;;
		"2048")
			PROD_ID="0028"
			;;
		esac
		;;
	"apalis-t30")
		RAM_SIZE=1024
		echo "Enter the RAM size ( 1024 / 2048 ):"
		read RAM_SIZE
		case ${RAM_SIZE} in
		"1024") 
			PROD_ID="0026"
			;;
		"2048")
			PROD_ID="0025"
			;;
		esac
		;;
	"colibri-imx6")
		RAM_SIZE=256
		echo "Enter the RAM size ( 256 / 512 ):"
		read RAM_SIZE
		echo "Enter I for IT version, nothing otherwise"
		read IT
		if [ $RAM_SIZE -eq 512 ] ; then
			if [ "$IT"x = "Ix" ] ; then
				PROD_ID="0017"
			else
				PROD_ID="0015"
			fi
		else
			if [ "$IT"x = "Ix" ] ; then
				PROD_ID="0016"
			else
				PROD_ID="0014"
			fi
		fi
		;;
	"colibri-t20")
		RAM_SIZE=256
		echo "Enter the RAM size ( 256 / 512 ):"
		read RAM_SIZE
		echo "Enter I for IT version, nothing otherwise"
		read IT
		if [ $RAM_SIZE -eq 512 ] ; then
			if [ "$IT"x = "Ix" ] ; then
				PROD_ID="0022"
			else
				PROD_ID="0021"
			fi
		else
			if [ "$IT"x = "Ix" ] ; then
				PROD_ID="0024"
			else
				PROD_ID="0020"
			fi
		fi
		;;
	"colibri-t30")
		PROD_ID="0023"
		;;
	"colibri-vf")
		VF_TYPE=50
		echo "Enter the Module Type (50 for a Colibri VF50 or 61 for a Colibri VF61)"
		read VF_TYPE

		echo "Enter I for IT version, nothing otherwise"
		read IT
		if [ "$VF_TYPE" = "50" ] ; then
			if [ "$IT"x = "Ix" ] ; then
				PROD_ID="0013"
			else
				PROD_ID="0010"
			fi
		elif [ "$VF_TYPE" = "61" ] ; then
			if [ "$IT"x = "I"x ] ; then
				PROD_ID="0012"
			else
				PROD_ID="0011"
			fi
		fi
		;;
	esac

	echo "Enter the module version, e.g. V1.2 C"
	read PRODVERSION
	VER_MAJ=`echo $PRODVERSION | awk 'BEGIN{ FIELDWIDTHS = "1 1 1 1 1 1"} {print $2}'`
	VER_MIN=`echo $PRODVERSION | awk 'BEGIN{ FIELDWIDTHS = "1 1 1 1 1 1"} {print $4}'`
	#VARIANT: A=0, B=1 ...
	VARIANT=`echo $PRODVERSION | awk 'BEGIN{ FIELDWIDTHS = "1 1 1 1 1 1"} {print $6}'`
	VARIANT=`printf "%d\n" "'$VARIANT"`
	VARIANT=`expr $VARIANT - 65`
	if [ "$VARIANT" -lt 10 ] ; then
		VARIANT=0$VARIANT
	fi
	PRODUCTNR=${PROD_ID}${VER_MAJ}${VER_MIN}${VARIANT}
fi

#write the config block file
if [ "${MODTYPE}" = "colibri-t20" ] ; then
	PROD_ID=`echo $PRODUCTNR | awk 'BEGIN{ FIELDWIDTHS = "4 4"} {print $1}'`
	CONFIGBLOCK_FILE=${MODTYPE}_bin/configblock_256.bin
	if [ ${PROD_ID} = "0021" ] ; then
		CONFIGBLOCK_FILE=${MODTYPE}_bin/configblock_512.bin
	fi
	if [ ${PROD_ID} = "0022" ] ; then
		CONFIGBLOCK_FILE=${MODTYPE}_bin/configblock_512.bin
	fi
else
	CONFIGBLOCK_FILE=${MODTYPE}_bin/configblock.bin
fi
sudo chown ${USER}: `dirname $CONFIGBLOCK_FILE`
sudo rm -f $CONFIGBLOCK_FILE
#file header
awk 'function sc(c) {return (c<128?c:(c-256))} BEGIN{printf "%c%c%c%c",0,64,1,-49}' > $CONFIGBLOCK_FILE
#mac addr / serial
echo $SERIALNR | awk 'function sc(c) {return (c<128?c:(c-256))} {printf "%c%c%c%c%c%c%c%c%c%c%c%c",2,64,0,0, 0,20,45, sc(int($0/256/256)), sc(int($0/256)%256), sc($0%256),0,0 }' >> $CONFIGBLOCK_FILE
#product describtion, $1 char 0/1: ??, $2 char 2/3: ProdID, $3 char 4:VerMaj, $4 char 5:VerMin, $5 char 6/7:Variant
echo $PRODUCTNR | awk 'BEGIN{ FIELDWIDTHS = "2 2 1 1 2"} function sc(c) {return (c<128?c:(c-256))} {printf "%c%c%c%c%c%c%c%c%c%c%c%c",2,64,8,0 ,sc($3),0, sc($4),0, sc($5),0, sc($2),0 }' >> $CONFIGBLOCK_FILE
#fill to 32 bytes
awk 'function sc(c) {return (c<128?c:(c-256))} BEGIN{printf "%c%c%c%c",-1,-1,-1,-1}' >> $CONFIGBLOCK_FILE

exit 0
