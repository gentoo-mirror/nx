# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

inherit nxserver_1.5

DEPEND="$DEPEND
	!net-misc/nxserver-personal
	!net-misc/nxserver-enterprise
	!net-misc/nxserver-freenx"

RDEPEND="${DEPEND}"

MY_PV="${PV}-91"
MY_EDITION="business"
MY_DOWNLOAD="http://web04.nomachine.com/download/1.5.0/server/standard/nxserver-${MY_PV}.i386.rpm"
SRC_URI="http://web04.nomachine.com/download/1.5.0/server/standard/nxserver-${MY_EDITION}-${MY_PV}.i386.rpm"
KEYWORDS="~x86"
IUSE=""
