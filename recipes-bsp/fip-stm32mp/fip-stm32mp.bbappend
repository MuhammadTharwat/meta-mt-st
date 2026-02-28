LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = "\
    file://ram_boot.tsv \
    file://usb_boot.sh \
    "

do_deploy:append(){
    install -d ${DEPLOYDIR}/
    cp ${WORKDIR}/ram_boot.tsv ${DEPLOYDIR}/
    cp ${WORKDIR}/usb_boot.sh ${DEPLOYDIR}/
}