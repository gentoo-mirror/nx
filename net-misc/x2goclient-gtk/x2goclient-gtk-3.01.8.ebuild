# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit versionator eutils autotools

MAJOR_PV="$(get_version_component_range 1-2)"
FULL_PV="${MAJOR_PV}-$(get_version_component_range 3)"
DESCRIPTION="The X2Go GTK Client "
HOMEPAGE="http://x2go.berlios.de"
SRC_URI="http://x2go.obviously-nice.de/deb/pool-lenny/${PN}/${PN}_${FULL_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

S=${WORKDIR}/${PN}-${MAJOR_PV}

RDEPEND="dev-cpp/gtkmm
	dev-cpp/gconfmm
	dev-cpp/glibmm
	dev-cpp/libglademm"

DEPEND="${RDEPEND}
	dev-lang/perl
	dev-perl/XML-Parser
	net-print/cups"


src_prepare() {
	epatch "${FILESDIR}"/${PN}-${FULL_PV}.patch
	eautoreconf
}

src_install() {
	BINNAME="x2goclient_gtk"
	ICONDIR="/usr/share/${BINNAME}/png"

	dobin src/${BINNAME}
	dodoc README

	# glade files
	insinto /usr/share/x2goclient_gtk/glade
	doins glade/*

	# copying the icons

	insinto ${ICONDIR}
	doins png/*
	insinto ${ICONDIR}/icons/
	doins png/icons/*
	insinto ${ICONDIR}/icons/16x16
	doins png/icons/16x16/*
	insinto ${ICONDIR}/icons/32x32
	doins png/icons/32x32/*
	insinto ${ICONDIR}/icons/64x64
	doins png/icons/64x64/*
	insinto ${ICONDIR}/icons/128x128
	doins png/icons/128x128/*

	make_desktop_entry /usr/bin/${BINNAME} "X2Go GTK-Client" ${BINNAME}/128x128/x2go.png "Network"
}
