# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit versionator

MAJOR_PV="$(get_version_component_range 1-3)"
FULL_PV="${MAJOR_PV}-$(get_version_component_range 4)"
DESCRIPTION="The X2Go server"
HOMEPAGE="http://x2go.berlios.de"
SRC_URI="http://x2go.obviously-nice.de/deb/pool/${PN}/${PN}_${FULL_PV}_all.deb"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="net-misc/nx
	virtual/postgresql-server"

S=${WORKDIR}

src_unpack() {
	unpack ${A}
	cd "${S}"

	tar xozf data.tar.gz || die "failure unpacking data.tar.gz"

	# Needs testing, is it fully compatible with nxagent?
	sed -i -e "s/x2goagent/nxagent/" usr/bin/x2gostartagent || die "sed failed"
}

src_install() {
	dobin usr/bin/*
	dosbin usr/sbin/*
	
	exeinto /usr/share/x2go/script
	doexe usr/lib/x2go/script/x2gocreatebase.sh

	insinto /etc/x2go
	doins etc/x2go/sql
	#TODO write Gentoo initd file
}

pkg_postinst() {
	elog "To work, x2goserver needs a configured postgreSQL database"
	elog "Sample script to create the database can be found here:"
	elog "    /usr/share/x2go/script/x2gocreatebase.sh"
}
