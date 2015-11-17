# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="4"
inherit qt4-r2

MY_P="freenx-client-${PV}"

DESCRIPTION="A Qt-based NX client using nxcl"
HOMEPAGE="http://developer.berlios.de/projects/freenx/"
SRC_URI="http://dev.gentoo.org/~voyageur/distfiles/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="net-misc/nxcl
	dev-qt/qtcore:4
	dev-qt/qtgui:4"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}/${PN}"

src_prepare() {
	sed -i -e "s#id\.key#/usr/share/${PN}/id.key#" qtnxwindow.cpp || die "sed failed"
}

src_install() {
	dobin ${PN}
	dodoc README

	insinto /usr/share/${PN}
	doins id.key
}
