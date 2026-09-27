# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1 systemd toolchain-funcs udev

MY_PV="${PV%%-r*}"

DESCRIPTION="Hardware support tools, kernel configs, and tablet mode daemon for Chuwi convertibles"
HOMEPAGE="https://github.com/madgagarin/chuwi-linux-tools"
SRC_URI="https://github.com/madgagarin/chuwi-linux-tools/archive/refs/tags/v${MY_PV}.tar.gz -> ${PN}-${MY_PV}.tar.gz"
S="${WORKDIR}/${PN}-${MY_PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="systemd dbus"

DEPEND="
	dbus? ( sys-apps/dbus )
"
RDEPEND="
	${DEPEND}
	virtual/udev
"
BDEPEND="
	virtual/pkgconfig
"

CONFIG_CHECK="~MXC4005 ~SERIAL_MULTI_INSTANTIATE ~INPUT_UINPUT ~IIO ~IIO_BUFFER"

src_compile() {
	# 1. Compile kernel module cmx.ko
	local modlist=( cmx=misc:cmx )
	local modargs=( KDIR="${KV_DIR}" )
	linux-mod-r1_src_compile

	# 2. Compile cmxd daemon & libcmx.so
	local dbus_opt=0
	use dbus && dbus_opt=1
	emake -C cmxd CC="$(tc-getCC)" ENABLE_DBUS=${dbus_opt} PREFIX="/usr"

	# 3. Compile cmxsd session daemon
	emake -C cmxsd CC="$(tc-getCC)" PREFIX="/usr"
}

src_install() {
	# 1. Install kernel module
	linux-mod-r1_src_install

	# 2. Install cmxd, cmxsd binaries and libraries
	dosbin cmxd/cmxd
	dobin cmxsd/cmxsd
	dolib.so cmxd/libcmx.so*
	insinto /usr/include/libcmx
	doins cmxd/src/cmxd-protocol.h

	# 3. Install OpenRC and systemd service files
	newinitd "${FILESDIR}/cmxd.initd" cmxd
	newconfd "${FILESDIR}/cmxd.confd" cmxd
	if use systemd; then
		systemd_dounit "${FILESDIR}/cmxd.service"
	fi

	# 4. Install patch for gentoo-kernel and gentoo-sources
	insinto /etc/portage/patches/sys-kernel/gentoo-kernel
	doins "${FILESDIR}/cmx.patch"
	insinto /etc/portage/patches/sys-kernel/gentoo-sources
	doins "${FILESDIR}/cmx.patch"

	# 5. Install kernel configuration snippet for automatic sensor and hardware merging
	insinto /etc/kernel/config.d
	doins "${FILESDIR}/50-chuwi-sensors.config"

	# 6. Install hardware kernel configs for reference into /usr/share
	insinto /usr/share/${PN}/kernel-configs
	doins "${FILESDIR}/kernel-config-chuwi-freebook-i5-1215u"
	doins "${FILESDIR}/50-chuwi-sensors.config"

	# 7. Install kernel module autoload configuration
	insinto /usr/lib/modules-load.d
	doins "${FILESDIR}/cmx.conf"

	# Documentation
	einstalldocs
}

pkg_postinst() {
	linux-mod-r1_pkg_postinst
	udev_reload

	elog "========================================================================"
	elog "Chuwi Linux Tools (${PVR}) has been installed successfully!"
	elog "========================================================================"
	elog ""
	elog "Installed hardware support files:"
	elog "  * Kernel patch:         /etc/portage/patches/sys-kernel/gentoo-kernel/cmx.patch"
	elog "  * Hardware config:      /etc/kernel/config.d/50-chuwi-sensors.config"
	elog "  * Device kernel config: /usr/share/chuwi-linux-tools/kernel-configs/"
	elog "  * Module autoload:      /usr/lib/modules-load.d/cmx.conf"
	elog ""
	elog "Optional ultra-fast kernel configuration (savedconfig):"
	elog "  To use the minimal ~2-minute Chuwi FreeBook kernel config:"
	elog "  # cp /usr/share/chuwi-linux-tools/kernel-configs/kernel-config-chuwi-freebook-i5-1215u \\"
	elog "       /etc/portage/savedconfig/sys-kernel/gentoo-kernel"
	elog ""
	elog "Service management (OpenRC):"
	elog "  # rc-update add cmxd default"
	elog "  # rc-service cmxd start"
	elog "  (Or for systemd: systemctl enable --now cmxd)"
	elog "========================================================================"
}
