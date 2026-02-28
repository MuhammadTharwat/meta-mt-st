FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = "\
    file://boot_cmd.cfg \
    file://boot_time_optimization.cfg \
    file://distro_bootcmd.env \
    "

do_configure:append(){
    cp ${WORKDIR}/distro_bootcmd.env ${S}/board/st/stm32mp1/.
}