# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils rpm

DESCRIPTION="NXNODE is a of NX components that are needed by the various NX servers."
HOMEPAGE="http://www.nomachine.com"

IUSE="rdesktop vnc prebuilt"
LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror strip"

URI_BASE="http://web04.nomachine.com/download/2.0.0/Linux"
SRC_NXCLIENT="${P}-98.i386.rpm"
SRC_URI="${URI_BASE}/${SRC_NXCLIENT}"

DEPEND="~net-misc/nxclient-2.0.0

	prebuilt? ( !net-misc/nxnode-base )
	!prebuilt? ( net-misc/nxnode-base )

	|| (  ( x11-libs/libICE
		x11-libs/libSM
		x11-libs/libXaw
		x11-libs/libXmu
		x11-libs/libXpm
		x11-libs/libXt
	      )
		virtual/x11
	   )"

RDEPEND="${DEPEND}"

S=${WORKDIR}

src_install() {
	cp -dPR usr ${D}

	# These will be provided by our dependencies
	rm -f ${D}/usr/NX/lib/libesd*

	# We need to remove these items if the user wishes to compile
	# the OSS components. All these will be delivered by:
	# nxnode-base-2.0.0
	if ! use prebuilt ; then
		rm -f ${D}/usr/NX/lib/libXcompext.so*
		rm -f ${D}/usr/NX/bin/nx{agent,desktop,passwd,sensor,spool,uexec,viewer}
	fi

	if use prebuilt  && ! use rdesktop ; then
		rm -f ${D}/usr/NX/bin/nxdesktop
	fi

	if use prebuilt  && ! use vnc ; then
		rm -f ${D}/usr/NX/bin/nx{passwd,viewer}
	fi

	# If we did not remove the files from above, then we need
	# to make some wrappers to the /usr/NX/lib dir. Again
	# This is testing to see if this works better.
	if use prebuilt ; then
		mv ${D}/usr/NX/bin/nxagent ${D}/usr/NX/bin/nxagent.bin
		make_wrapper nxagent nxagent.bin /usr/NX/bin /usr/NX/lib /usr/NX/bin

		if use vnc ; then
			mv ${D}/usr/NX/bin/nxviewer ${D}/usr/NX/bin/nxviewer.bin
			make_wrapper nxviewer nxviewer.bin /usr/NX/bin /usr/NX/lib /usr/NX/bin
		fi

		if use rdesktop ; then
			mv ${D}/usr/NX/bin/nxdesktop ${D}/usr/NX/bin/nxdesktop.bin
			make_wrapper nxdesktop nxdesktop.bin /usr/NX/bin /usr/NX/lib /usr/NX/bin
		fi
	fi
}
