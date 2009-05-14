# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#TODO: need gentoo init script

EAPI=2

inherit distutils

DESCRIPTION="Remote Desktop Server"
HOMEPAGE="https://launchpad.net/tacix"
SRC_URI="http://launchpad.net/${PN}/0.1/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="net-misc/nx
	sys-apps/dbus
	sys-auth/consolekit"

export NX_HOME_DIR=/var/lib/nxserver/home

pkg_setup () {
	enewuser nx -1 -1 ${NX_HOME_DIR}
}

src_install() {
	distutils_src_install

	# For logs
	keepdir ${NX_HOME_DIR}/.nx
	fowners nx ${NX_HOME_DIR}/.nx
}

pkg_postinst () {
	distutils_pkg_postinst
	# Other NX servers ebuilds may have already created the nx account
	# However they use different login shell/home directory paths
	if [[ ${ROOT} == "/" ]]; then
		usermod -s /usr/lib/tacix/tacix-freenx-server nx || die "Unable to set login shell of nx user!!"
		usermod -d ${NX_HOME_DIR} nx || die "Unable to set home directory of nx user!!"
	else
		elog "If you had another NX server installed before, please make sure"
		elog "the nx user account is correctly set to:"
		elog " * login shell: /usr/lib/tacix/tacix-freenx-server"
		elog " * home directory: ${NX_HOME_DIR}"
	fi

	if ! built_with_use net-misc/openssh pam; then
		elog ""
		elog "net-misc/openssh was not built with PAM support"
		elog "You will need to unlock the nx account by setting a password for it"
	fi
}
