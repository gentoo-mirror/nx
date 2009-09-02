# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit versionator

MY_P="${PN}_$(replace_version_separator 3 -)"
DESCRIPTION="The X2Go server"
HOMEPAGE="http://x2go.berlios.de"
SRC_URI="http://x2go.obviously-nice.de/deb/pool-lenny/${PN}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+fuse postgres +sqlite"

DEPEND=""
RDEPEND="app-admin/sudo
	net-misc/nx
	virtual/ssh
	fuse? ( sys-fs/sshfs-fuse )
	postgres? ( virtual/postgresql-server )
	sqlite? ( !postgres? ( >=dev-db/sqlite-3 ) )"

S="${WORKDIR}/${PN}-$(get_version_component_range 1-3)"

pkg_setup() {
	if use postgres && use sqlite ; then
		ewarn "You have selected both PostgreSQL and SQLite. This installation of x2goserver"
		ewarn "will default to PostgreSQL. Add USE=-postgres if you prefer SQLite."
	fi
	if use !postgres && use !sqlite ; then
		ewarn "You have selected neither PostgreSQL or SQLite as a database. You will need"
		ewarn "to use a remote PostgreSQL database."
	fi
}

src_prepare() {
	# Needs testing, is it fully compatible with nxagent?
	sed -i -e 's/x2goagent/nxagent/' x2gostartagent || die "sed failed"

	sed -i -e 's/sqlite/sqlite3/' x2gosqlite.sh || die "sed failed"

	cp "${FILESDIR}"/${PN}.init .
	if use !postgres ; then
		sed -i -e '/need postgresql/d' ${PN}.init || die "sed failed"
	fi
}

src_install() {
	exeinto /usr/share/x2go/script
	doexe x2go*.sh
	rm x2go*.sh

	dosbin x2gocleansessions
	rm x2gocleansessions

	dobin x2go*

	mkdir -p "${D}/etc/x2go"
	if use postgres ; then
		echo -n local > "${D}/etc/x2go/sql"
	elif use sqlite ; then
		echo -n sqlite > "${D}/etc/x2go/sql"
	else echo -n "Replace this with your remote PostgreSQL server's address" > "${D}/etc/x2go/sql"
	fi

	newinitd ${PN}.init ${PN}

	dodoc INSTALL debian/changelog

	keepdir /var/db/x2go
}

pkg_postinst() {
	if use postgres ; then
		elog "You have selected a PostgreSQL database. If you are installing x2goserver for"
		elog "the first time you need to create the database with the following script:"
		elog "/usr/share/x2go/script/x2gocreatebase.sh"
		elog "If you are changing to PostreSQL from SQLite you need to remove the old"
		elog "database at /var/db/x2go/x2go_sessions and run the above script."
	elif use sqlite ; then
		elog "You have selected an SQLite database. If you are installing x2goserver for"
		elog "the first time you need to create the database with the following script:"
		elog "/usr/share/x2go/script/x2gosqlite.sh"
		elog "If you are changing to SQLite from PostreSQL you need to remove the old"
		elog "database at /var/db/x2go/x2go_sessions and run the above script."
	else
		elog "You have selected a remote database. You will need to specify the address of"
		elog "your remote PostgreSQL server in /etc/x2go/sql."
	fi
	einfo ""
	elog "You will need to give sudo rights on x2gopgwrapper to your users"
	elog "A sudoers example for all members of the group users:"
	elog "    %users ALL=(ALL) NOPASSWD: /usr/bin/x2gopgwrapper"
	elog "To give only a special group access to the x2goserver, "
	elog "change %users to any other group"
}
