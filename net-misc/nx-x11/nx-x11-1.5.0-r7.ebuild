# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="A special version of the X11 libraries supporting NX compression technology"
HOMEPAGE="http://www.nomachine.com/developers.php"

URI_BASE="http://web04.nomachine.com/download/1.5.0/sources"
SRC_NX_X11="nx-X11-$PV-21.tar.gz"
SRC_NXAGENT="nxagent-$PV-112.tar.gz"
SRC_NXAUTH="nxauth-$PV-1.tar.gz"
SRC_NXCOMP="nxcomp-$PV-80.tar.gz"
SRC_NXCOMPEXT="nxcompext-$PV-20.tar.gz"
SRC_NXDESKTOP="nxdesktop-$PV-78.tar.gz"
SRC_NXVIEWER="nxviewer-$PV-15.tar.gz"

SRC_URI="$URI_BASE/$SRC_NX_X11 $URI_BASE/$SRC_NXAGENT $URI_BASE/$SRC_NXAUTH
	$URI_BASE/$SRC_NXCOMP $URI_BASE/$SRC_NXCOMPEXT
	rdesktop? ( $URI_BASE/$SRC_NXDESKTOP )
	vnc? ( $URI_BASE/$SRC_NXVIEWER )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="rdesktop vnc"

DEPEND="~net-misc/nxproxy-1.5.0
	app-text/rman"

S=${WORKDIR}/${PN//x11/X11}

src_unpack() {
	# we can't use ${A} because of bug #61977
	unpack ${SRC_NX_X11}
	unpack ${SRC_NXAGENT}
	unpack ${SRC_NXAUTH}
	unpack ${SRC_NXCOMP}
	unpack ${SRC_NXCOMPEXT}
	use rdesktop && unpack ${SRC_NXDESKTOP}
	use vnc && unpack ${SRC_NXVIEWER}

	cd ${S}
	epatch ${FILESDIR}/1.5.0/nx-x11-windows-linux-resume.patch
	epatch ${FILESDIR}/1.5.0/plastik-render-fix-1.5.0.patch
	cd ../nxcomp
	epatch ${FILESDIR}/1.5.0/nxcomp-1.5.0-r1-gcc4.patch
	epatch ${FILESDIR}/1.5.0/nxcomp-1.5.0-r1-pic.patch
}

src_compile() {
	emake World || die "unable to build nx-x11"

	if use vnc ; then
		cd ../nxviewer
		xmkmf || die "unable to create makefile for nxviewer"
		emake World || die "unable to make nxviewer"
	fi

	if use rdesktop ; then
		cd ../nxdesktop
		./configure --prefix=/usr/NX --mandir=/usr/share/man --sharedir=/usr/share || die "Unable to configure nxdesktop"
		emake || die "Unable to build nxdesktop"
	fi
}

src_install() {
	into /usr/NX

	dobin programs/Xserver/nxagent
	dobin programs/nxauth/nxauth

	if use vnc ; then
		dobin ../nxviewer/nxviewer/nxviewer
		dobin ../nxviewer/nxpasswd/nxpasswd
	fi

	if use rdesktop ; then
		dobin ../nxdesktop/nxdesktop
	fi

	dolib.so lib/X11/libX11.so*

	dolib.so lib/Xext/libXext.so*

	dolib.so lib/Xrender/libXrender.so*

	dolib.so ../nxcompext/libXcompext.so*

	dodir /var/lib/nxserver
}
