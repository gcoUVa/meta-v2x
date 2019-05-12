FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://0001-ath9k-ocb.patch"
SRC_URI += "file://0001-pcie-designware.patch"
SRC_URI += "file://80211pconfig"

KERNEL_DEFCONFIG_solidrun-imx6 = "${WORKDIR}/80211pconfig"

# DEFAULT_PREFERENCE = "1"

do_merge_delta_config[dirs] = "${B}"

do_merge_delta_config() {
    # allow getting KERNEL_DEFCONFIG from outside of the kernel source tree
    cp ${KERNEL_DEFCONFIG} ${S}/arch/${ARCH}/configs/yocto_defconfig

    # create .config with make config
    oe_runmake -C ${S} O=${B} yocto_defconfig

    # add config fragments
    for deltacfg in ${DELTA_KERNEL_DEFCONFIG}; do
        if [ -f "${S}/arch/${ARCH}/configs/${deltacfg}" ]; then
            oe_runmake -C ${S} O=${B} ${deltacfg}
        elif [ -f "${WORKDIR}/${deltacfg}" ]; then
            ${S}/scripts/kconfig/merge_config.sh -m .config ${WORKDIR}/${deltacfg}
        elif [ -f "${deltacfg}" ]; then
            ${S}/scripts/kconfig/merge_config.sh -m .config ${deltacfg}
        fi
    done
    cp .config ${WORKDIR}/defconfig
}
addtask merge_delta_config before do_preconfigure after do_patch

COMPATIBLE_MACHINE = "solidrun-imx6"

