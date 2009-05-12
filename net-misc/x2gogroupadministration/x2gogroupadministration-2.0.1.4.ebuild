# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit kde versionator

MAJOR_PV="$(get_version_component_range 1-3)"
FULL_PV="${MAJOR_PV}-$(get_version_component_range 4)"
DESCRIPTION="The X2Go KControl group administration module"
HOMEPAGE="http://x2go.berlios.de"
#SRC_URI="http://x2go.obviously-nice.de/deb/pool/${PN}/${PN}_${MAJOR_PV}.orig.tar.gz http://x2go.obviously-nice.de/deb/pool/${PN}/${PN}_${FULL_PV}.diff.gz"
SRC_URI="http://x2go.obviously-nice.de/deb/pool-lenny/${PN}/${PN}_${FULL_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

need-kde 3

S=${WORKDIR}/${PN}-${MAJOR_PV}

src_unpack(){
	unpack ${A}
        epatch "${FILESDIR}"/${PN}-2.0.1.4-ldap.patch
#	epatch "${DISTDIR}/${PN}_${FULL_PV}.diff.gz"
}

pkg_postinst(){
        elog "The gentoo x2go ebuilds now need a different"
        elog "  /etc/x2go/x2goldaptools.conf from the original one."
        elog "You must add:"
        elog "    bindn=\"cn=yourldap,ou=bind,c=dn\""
        elog "    binddnpw=\"yourbindpassword\""
        elog "The quotes must be normal quotes and the lines must be added at the end!"
        elog "Make sure you secure the file by good permissions like 0600 and owner root!"

}
