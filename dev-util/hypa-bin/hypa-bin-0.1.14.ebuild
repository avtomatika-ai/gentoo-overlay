# Copyright 2026 Dmitrii Gagarin (@madgagarin)
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit avtomatika

DESCRIPTION="Context optimisation CLI for AI harnesses"
HOMEPAGE="https://github.com/Hypabolic/Hypa"

SRC_URI="
	amd64? ( https://github.com/Hypabolic/Hypa/releases/download/v${PV}/hypa-linux-x64.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( https://github.com/Hypabolic/Hypa/releases/download/v${PV}/hypa-linux-arm64.tar.gz -> ${P}-arm64.tar.gz )
"

LICENSE="FSL-1.1-ALv2"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	sys-libs/glibc
"

RESTRICT="mirror strip"
QA_PREBUILT="*"

S="${WORKDIR}"

src_install() {
	local my_arch
	use amd64 && my_arch="x64"
	use arm64 && my_arch="arm64"

	local sourcedir="${WORKDIR}/hypa-linux-${my_arch}"

	insinto /opt/hypa
	doins -r "${sourcedir}"/*
	fperms 0755 /opt/hypa/hypa

	dosym -r /opt/hypa/hypa /usr/bin/hypa
}
