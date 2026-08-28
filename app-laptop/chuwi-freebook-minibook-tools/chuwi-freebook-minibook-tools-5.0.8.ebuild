# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1 systemd toolchain-funcs udev

MY_COMMIT="db01ab812d7df5776fbc6e3d0e6991c407cc4db3"

DESCRIPTION="Hardware support tools and daemons for Chuwi FreeBook and MiniBook X convertibles"
HOMEPAGE="https://github.com/greymouser/minibook-x-tools"
SRC_URI="https://github.com/greymouser/minibook-x-tools/archive/${MY_COMMIT}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/minibook-x-tools-${MY_COMMIT}"

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

src_prepare() {
	default
	eapply "${FILESDIR}/cmx-freebook-dmi.patch"
}

src_compile() {
	# 1. Compile kernel module cmx.ko
	local modlist=( cmx=misc:cmx )
	local modargs=( KDIR="${KV_DIR}" )
	linux-mod-r1_src_compile

	# 2. Compile cmxd daemon & libcmx.so
	local dbus_opt=0
	use dbus && dbus_opt=1
	emake -C cmxd CC="$(tc-getCC)" ENABLE_DBUS=${dbus_opt} PREFIX="/usr"
}

src_install() {
	# 1. Install kernel module
	linux-mod-r1_src_install

	# 2. Install cmxd binary and libraries
	dosbin cmxd/cmxd
	dolib.so cmxd/libcmx.so*
	insinto /usr/include/libcmx
	doins cmxd/src/cmxd-protocol.h

	# 3. Install OpenRC and systemd service files
	newinitd "${FILESDIR}/cmxd.initd" cmxd
	newconfd "${FILESDIR}/cmxd.confd" cmxd
	if use systemd; then
		systemd_dounit "${FILESDIR}/cmxd.service"
		insinto /etc/default
		newins "${FILESDIR}/cmxd.default" cmxd
	fi

	# 4. Install kernel config snippet for dist-kernel / gentoo-kernel
	insinto /etc/kernel/config.d
	doins "${FILESDIR}/50-chuwi-sensors.config"

	# 5. Install patch for gentoo-kernel
	insinto /etc/portage/patches/sys-kernel/gentoo-kernel
	doins "${FILESDIR}/cmx.patch"
	insinto /etc/portage/patches/sys-kernel/gentoo-sources
	doins "${FILESDIR}/cmx.patch"

	# 6. Install optimized kernel config for Chuwi FreeBook 360 i5-1215U
	insinto /usr/share/${PN}/kernel-configs
	doins "${FILESDIR}/kernel-config-chuwi-freebook-i5-1215u"
	insinto /etc/portage/savedconfig/sys-kernel
	newins "${FILESDIR}/kernel-config-chuwi-freebook-i5-1215u" gentoo-kernel

	# 7. Install kernel module autoload configuration
	insinto /usr/lib/modules-load.d
	doins "${FILESDIR}/cmx.conf"

	# Documentation
	einstalldocs
}

pkg_postinst() {
	linux-mod-r1_pkg_postinst
	udev_reload

	elog "Chuwi FreeBook & MiniBook X tools have been installed successfully."
	elog ""
	elog "1. The kernel patch has been placed into:"
	elog "   /etc/portage/patches/sys-kernel/gentoo-kernel/cmx.patch"
	elog "2. The kernel config snippet has been placed into:"
	elog "   /etc/kernel/config.d/50-chuwi-sensors.config"
	elog "3. The optimized 2-minute kernel config has been placed into:"
	elog "   /etc/portage/savedconfig/sys-kernel/gentoo-kernel"
	elog "4. Enable and start the daemon under OpenRC:"
	elog "   rc-update add cmxd default"
	elog "   rc-service cmxd start"
	elog "   (Or for systemd: systemctl enable --now cmxd)"
}
