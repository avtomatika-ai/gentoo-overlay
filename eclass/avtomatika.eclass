# Copyright 2026 Dmitrii Gagarin (@madgagarin)
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: avtomatika.eclass
# @MAINTAINER:
# Dmitrii Gagarin <madgagarin@gmail.com>
# @AUTHOR:
# Dmitrii Gagarin (@madgagarin)
# @BLURB: Common eclass for Avtomatika AI overlay packages.
# @DESCRIPTION:
# Provides unified branding and standard phase defaults for packages
# in the Avtomatika AI overlay.

if [[ -z ${_AVTOMATIKA_ECLASS} ]]; then
_AVTOMATIKA_ECLASS=1

# @FUNCTION: avtomatika_print_banner
# @DESCRIPTION:
# Prints package information and overlay maintenance details.
avtomatika_print_banner() {
	elog "=========================================================="
	elog "   Avtomatika AI Infrastructure Layer"
	elog "   Package:    ${CATEGORY}/${PN}-${PV}"
	elog "   Maintainer: Dmitrii Gagarin (@madgagarin)"
	elog "   Company:    Avtomatika AI (https://avtomatika.ai)"
	elog "   Issues:     https://github.com/avtomatika-ai/gentoo-overlay/issues"
	elog "=========================================================="
}

EXPORT_FUNCTIONS pkg_postinst

avtomatika_pkg_postinst() {
	avtomatika_print_banner
}

fi
