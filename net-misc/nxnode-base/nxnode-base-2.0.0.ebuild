# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="A special version of the X11 libraries supporting NX compression technology"
HOMEPAGE="http://www.nomachine.com/developers.php"

URI_BASE="http://web04.nomachine.com/download/2.0.0/sources"
SRC_NX_X11="nx-X11-$PV-31.tar.gz"
SRC_NXAGENT="nxagent-$PV-89.tar.gz"
SRC_NXAUTH="nxauth-$PV-2.tar.gz"
SRC_NXCOMP="nxcomp-$PV-81.tar.gz"
SRC_NXCOMPEXT="nxcompext-$PV-33.tar.gz"
SRC_NXDESKTOP="nxdesktop-$PV-50.tar.gz"
SRC_NXSENSOR="nxsensor-$PV-2.tar.gz"
SRC_NXSPOOL="nxspool-$PV-4.tar.gz"
SRC_NXUEXEC="nxuexec-$PV-4.tar.gz"
SRC_NXVIEWER="nxviewer-$PV-15.tar.gz"

SRC_URI="${URI_BASE}/${SRC_NX_X11} ${URI_BASE}/${SRC_NXAGENT} ${URI_BASE}/${SRC_NXAUTH}
	${URI_BASE}/${SRC_NXCOMP} ${URI_BASE}/${SRC_NXCOMPEXT} ${URI_BASE}/${SRC_NXSENSOR}
	${URI_BASE}/${SRC_NXSPOOL} ${URI_BASE}/${SRC_NXUEXEC}
	rdesktop? ( ${URI_BASE}/${SRC_NXDESKTOP} )
	vnc? ( $URI_BASE/$SRC_NXVIEWER )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-amd64 ~ppc ~x86"
RESTRICT="mirror"
IUSE="rdesktop vnc"

DEPEND=">=media-libs/jpeg-6b-r7
	~net-misc/nxclient-2.0.0

	prebuilt? ( !net-misc/nxnode-base )
	!prebuilt? ( net-misc/nxnode-base )

	|| (  ( x11-libs/libICE
		x11-libs/libSM
		x11-libs/libXaw
		x11-libs/libXmu
		x11-libs/libXpm
		x11-libs/libXt
		x11-misc/gccmakedep
		x11-misc/imake
		app-text/rman
	      )
		virtual/x11
	   )"

RDEPEND="${DEPEND}"

S=${WORKDIR}

src_unpack() {
	# we can't use ${A} because of bug #61977
	unpack ${SRC_NXCOMP}
	unpack ${SRC_NXCOMPEXT}
	unpack ${SRC_NX_X11}
	unpack ${SRC_NXAGENT}
	unpack ${SRC_NXAUTH}
	unpack ${SRC_NXSENSOR}
	unpack ${SRC_NXSPOOL}
	unpack ${SRC_NXUEXEC}
	use rdesktop && unpack ${SRC_NXDESKTOP}
	use vnc && unpack ${SRC_NXVIEWER}

	cd ${S}
	epatch ${FILESDIR}/2.0.0/nxcomp-2.0.0-makefile.patch
	epatch ${FILESDIR}/2.0.0/nxcompext-2.0.0-makefile.patch
}

src_compile() {
	# builds: nxcomp, nxcompext, nx-x11, nxauth, nxagent
	cd nx-x11
	emake World || die "Unable to build nx-X11"

	# build nxsensor
	cd ../nxsensor
	emake || die "Unable to build nxsensor"

	# build nxspool
	cd ../nxspool/source
	econf --prefix=/usr/NX --mandir=/usr/share/man || die "Unable to configure nxspool"
	emake || die "Unable to build nxspool"

	# build nxuexec
	cd ../../nxuexec
	emake || die "Unable to build nxnxuexec"

	if use vnc ; then
		cd ../nxviewer
		xmkmf || die "unable to create makefile for nxviewer"
		emake World || die "unable to make nxviewer"
	fi

	if use rdesktop ; then
		cd ../nxdesktop
		econf --prefix=/usr/NX --mandir=/usr/share/man --sharedir=/usr/share || die "Unable to configure nxdesktop"
		emake || die "Unable to build nxdesktop"
	fi
}

src_install() {
	into /usr/NX

	# Rename to make a wrapper later that points to /usr/NX/libs
	newbin nx-x11/programs/Xserver/nxagent nxagent.bin
	make_wrapper nxagent nxagent.bin /usr/NX/bin /usr/NX/lib /usr/NX/bin

	# Not needed anymore? Let's test if it's not. ;)
	#dobin nx-x11/programs/nxauth/nxauth

	dobin nxsensor/nxsensor
	# I think this nxspool line is right. :S Very confusing.
	newbin nxspool/source/bin/smbspool nxspool
	dobin nxuexec/nxuexec

	if use vnc ; then
		newbin nxviewer/nxviewer/nxviewer nxviewer.bin
		make_wrapper nxviewer nxviewer.bin /usr/NX/bin /usr/NX/lib /usr/NX/bin
		dobin nxviewer/nxpasswd/nxpasswd
	fi

	if use rdesktop ; then
		newbin nxdesktop/nxdesktop nxdesktop.bin
		make_wrapper nxdesktop nxdesktop.bin /usr/NX/bin /usr/NX/lib /usr/NX/bin
	fi

	dolib.so nx-x11/lib/X11/libX11.so*
	dolib.so nx-x11/lib/Xext/libXext.so*
	dolib.so nx-x11/lib/Xrender/libXrender.so*
	dolib.so nxcompext/libXcompext.so*
}
