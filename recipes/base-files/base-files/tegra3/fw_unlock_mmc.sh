# Give fw_setenv mmcblk0boot1 write permissions
function fw_setenv() {
    echo 0 > /sys/block/mmcblk0boot1/force_ro
    /sbin/fw_setenv "$@"
    echo 1 > /sys/block/mmcblk0boot1/force_ro
}
