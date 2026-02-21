FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = "\
    file://target_update.sh \
    "

do_install:append() {
        install -m 755 -d ${D}${datadir}/mender/modules/v3
        install -m 755 ${WORKDIR}/target_update.sh ${D}${datadir}/mender/modules/v3/
}

FILES:${PN} += "\
    ${datadir}/mender/modules/v3/target_update.sh \
"

