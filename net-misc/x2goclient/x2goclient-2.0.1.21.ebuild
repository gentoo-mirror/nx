# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"
inherit qt4 versionator

MAJOR_PV="$(get_version_component_range 1-3)"
FULL_PV="${MAJOR_PV}-$(get_version_component_range 4)"
DESCRIPTION="The X2Go Qt client"
HOMEPAGE="http://x2go.berlios.de"
SRC_URI="http://x2go.obviously-nice.de/deb/pool/${PN}/${PN}_${FULL_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="net-misc/nx
	net-nds/openldap
	|| ( ( x11-libs/qt-core:4 x11-libs/qt-gui:4 x11-libs/qt-svg:4 )
		>=x11-libs/qt-4.3:4 )"

S=${WORKDIR}/${PN}-${MAJOR_PV}

src_compile() {
	eqmake4
	emake || die "emake failed"
}

src_install() {
	dobin ${PN}
	dodoc README
}
