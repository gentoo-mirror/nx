# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils qt3

DESCRIPTION=""
HOMEPAGE=""
SRC_URI="http://code.2x.com/release/linuxterminalserver/src/linuxterminalserver-1.5.0-r21-src.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-libs/glib
	dev-libs/openssl
	media-libs/gd
	media-libs/jpeg
	media-libs/libpng
	net-print/cups
	sys-libs/zlib
	=x11-libs/qt-3*
	!net-misc/nxclient"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_unpack()
{
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/1.5.0/nxcomp-1.5.0-gcc4.patch
	epatch ${FILESDIR}/1.5.0/nxcomp-1.5.0-pic.patch
}

src_compile()
{
	cd ${S}/common/nxcomp
	econf || die
	emake || die

	cd ${S}/common/nxssh
	econf || die
	emake || die
	
	cd ${S}/client/nxesd
	econf || die
	emake || die

	cd ${S}/client/nxclient
	econf || die
	emake || die

	cd ${S}/client/nxclient/nxprint
	emake || die
}

src_install() {
	# we install into /usr/NX, as NoMachine and 2X do

	for x in nxclient nxprint nxssh nxesd ; do
		make_wrapper $x ./$x /usr/NX/bin /usr/NX/lib || die
	done

	into /usr/NX
	dobin client/nxclient/nxclient 
	dobin client/nxclient/nxprint/nxprint
	dobin client/nxesd/nxesd 
	dobin common/nxssh/nxssh

	# TODO: cp must be used, hardcoded /usr/NX/lib
	dodir /usr/NX/lib
	cp -P common/nxcomp/libXcomp.so* ${D}/usr/NX/lib || die

	dodir /usr/NX/share
	cp -R client/nxclient/share ${D}/usr/NX || die

	# TODO: add icons/desktop entries
}
