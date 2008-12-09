# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit kde versionator

MAJOR_PV="$(get_version_component_range 1-3)"
FULL_PV="${MAJOR_PV}-$(get_version_component_range 4)"
DESCRIPTION="The X2Go KControl group administration module"
HOMEPAGE="http://x2go.berlios.de"
SRC_URI="http://x2go.obviously-nice.de/deb/pool/${PN}/${PN}_${MAJOR_PV}.orig.tar.gz http://x2go.obviously-nice.de/deb/pool/${PN}/${PN}_${FULL_PV}.diff.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

need-kde 3

S=${WORKDIR}/${PN}-${MAJOR_PV}.orig

src_unpack(){
	unpack ${A}
	epatch "${DISTDIR}/${PN}_${FULL_PV}.diff.gz"
}
