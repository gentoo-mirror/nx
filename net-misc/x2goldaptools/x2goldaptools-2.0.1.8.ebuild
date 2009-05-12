# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"
inherit versionator

MAJOR_PV="$(get_version_component_range 1-3)"
FULL_PV="${MAJOR_PV}-$(get_version_component_range 4)"
DESCRIPTION="The X2Go ldap tools"
HOMEPAGE="http://x2go.berlios.de"
SRC_URI="http://x2go.obviously-nice.de/deb/pool-lenny/${PN}/${PN}_${FULL_PV}_all.deb"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="net-nds/openldap
	net-nds/smbldap-tools"

S=${WORKDIR}/${PN}-${MAJOR_PV}.orig

src_unpack(){
	unpack ${A}
	cd "${S}"

	tar xozf data.tar.gz || die "failure unpacking data.tar.gz"
}

src_install() {
	dobin usr/bin/*
	dosbin usr/sbin/*

	insinto /etc/x2go
	doins usr/share/x2goldaptools/config/etc.orig/x2go/*

	exeinto /usr/share/x2goldaptools/script
	doexe usr/share/x2goldaptools/script/*

	exeinto /usr/share/x2goldaptools/config
	doexe usr/share/x2goldaptools/config/genconf
}

pkg_postinst() {
	elog "Use genconf to generate config files"
	elog "  /usr/share/x2goldaptools/config/genconf"
	elog ""
	elog "Use makeCA to generate CA"
	elog "  /usr/share/x2goldaptools/script/makeCA"
	elog ""
	elog "Use makenewcert to generate SSL cert for slapd"
	elog "  /usr/share/x2goldaptools/script/makenewcert"
	elog ""
	elog "Use initsystem to create database"
	elog "  /usr/share/x2goldaptools/script/initsystem"
	elog ""
	elog "To use the X2Go-Kcontrolmodules, append to"
	elog "  /etc/x2go/x2goldaptools.conf"
	elog "the lines (order and quotes are important!)"
	elog "  binddn=\"cn=your,o=bind,c=dn\""
	elog "  binddnpw=\"yourbindpassword\""
	elog "and make sure you secure the file"
}
