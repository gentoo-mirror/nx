# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/nxserver-personal/nxserver-personal-1.4.0-r3.ebuild,v 1.1 2005/05/23 18:57:23 stuart Exp $

inherit nxserver_1.5

DEPEND="$DEPEND
	!net-misc/nxserver-personal
	!net-misc/nxserver-business
	!net-misc/nxserver-freenx"

RDEPEND="${DEPEND}"

MY_PV="${PV}-91"
MY_EDITION="enterprise"
MY_DOWNLOAD="http://web04.nomachine.com/download/1.5.0/server/enterprise/nxserver-${MY_PV}.i386.rpm"
SRC_URI="http://web04.nomachine.com/download/1.5.0/server/enterprise/nxserver-${MY_EDITION}-${MY_PV}.i386.rpm"
KEYWORDS="~x86"
IUSE=""
