# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit webapp

DESCRIPTION="web companion client for NoMachine NX servers"
HOMEPAGE="http://www.nomachine.com/"

SRC_URI="http://64.34.161.181/download/${PV}/Linux/nxplugin-${PV}-5.i386.tar.gz"
LICENSE="nomachine"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=net-misc/nxserver-freeedition-3.0.0"
RDEPEND="${DEPEND}"

src_install() {
	webapp_src_preinst

	einfo "Patching nxapplet.html with server hostname: ${VHOST_HOSTNAME}"
	sed -i -e "s|http://webserver|http://${VHOST_HOSTNAME}/${PN}|" usr/NX/share/plugin/nxapplet.html
	[ "$VHOST_HOSTNAME" = localhost ] && ewarn "Server hostname is localhost, the plugin will not be usable from remote hosts"

	cp -R usr/NX/share/* ${D}/${MY_HTDOCSDIR}

	#TODO: webapp_postinst_txt en ${FILESDIR}/postinstall-en.txt
	# Note to the user that she can access the client at http://localhost/nxweb/plugin/nxapplet.html

	webapp_src_install
}
