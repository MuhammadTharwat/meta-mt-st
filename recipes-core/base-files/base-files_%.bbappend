FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://libcamera_env.sh"

do_install:append() {
    install -d ${D}/etc/profile.d/
    install -m 0755 ${WORKDIR}/libcamera_env.sh ${D}/etc/profile.d/
}

do_install:append () {
    cat >> ${D}${sysconfdir}/fstab <<EOF

# Mount Data Partition
/dev/mmcblk0p7	/data	ext4	rw,noatime	0	0

EOF
}
