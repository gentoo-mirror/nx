# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"
inherit versionator eutils

MAJOR_PV="$(get_version_component_range 1-3)"
FULL_PV="${MAJOR_PV}-$(get_version_component_range 4)"
DESCRIPTION="The X2Go usb mount tool"
HOMEPAGE="http://x2go.berlios.de"
SRC_URI="http://x2go.obviously-nice.de/deb/pool-lenny/${PN}/${PN}_${FULL_PV}_all.deb"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

S=${WORKDIR}/${PN}-${MAJOR_PV}.orig

src_unpack(){
unpack ${A}
        cd "${S}"

        tar xozf data.tar.gz || die "failure unpacking data.tar.gz"
}

src_install(){
    dosbin usr/sbin/*
    
    insinto /etc/udev/rules.d/
    doins etc/udev/rules.d/z60_x2gousb.rules
}
