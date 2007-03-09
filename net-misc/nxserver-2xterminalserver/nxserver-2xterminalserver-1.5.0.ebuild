# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit flag-o-matic eutils

DESCRIPTION="A X11/RDP/VNC proxy server especially well suited to low bandwidth links such as wireless, WANS, and worse"
HOMEPAGE="http://www.2x.com/terminalserver/"
SRC_URI="http://code.2x.com/release/linuxterminalserver/src/linuxterminalserver-1.5.0-r21-src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

# TODO: need cups?
DEPEND="
	dev-libs/glib
	dev-libs/openssl
	media-libs/gd
	media-libs/jpeg
	media-libs/libpng
	net-print/cups
	sys-libs/zlib
	net-misc/nxclient-2xterminalserver"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_unpack()
{
	unpack ${A}
	
	cd ${S}
	epatch ${FILESDIR}/1.5.0/nx-x11-1.5.0-amd64.patch || die
	epatch ${FILESDIR}/1.5.0/nx-x11-1.5.0-plastik-render-fix.patch || die
	epatch ${FILESDIR}/1.5.0/nx-x11-1.5.0-tmp-exec.patch || die
	epatch ${FILESDIR}/1.5.0/nx-x11-1.5.0-xorg7-font-fix.patch || die
	epatch ${FILESDIR}/1.5.0/nx-x11-1.5.0-windows-linux-resume.patch || die
	epatch ${FILESDIR}/1.5.0/nx-x11-1.5.0-external-nxcomp.patch || die
	epatch ${FILESDIR}/1.5.0/nxcompext-1.5.0-insitu.patch || die
	epatch ${FILESDIR}/1.5.0/nxdesktop-1.5.0-insitu.patch || die
	epatch ${FILESDIR}/1.5.0/nxviewer-1.5.0-insitu.patch || die
	epatch ${FILESDIR}/1.5.0/nxsensor-1.5.0-insitu.patch || die
	epatch ${FILESDIR}/1.5.0/nxnode-1.5.0-insitu.patch || die
}

build_nxagent()
{
	einfo
	einfo "Building nxcompext"
	einfo

	cd ${S}/common/nxcompext
	append-ldflags "-L/usr/NX/lib"
	econf || die
	emake || die
	
	einfo
	einfo "Building nx-X11"
	einfo
	
	cd ${S}/common/nx-X11
	emake World || die
}

build_nxdesktop()
{
	einfo
	einfo "Building nxdesktop"
	einfo

	cd ${S}/client/nxdesktop
	CC=(tc-getCC) ./configure || die

	emake || die
}

build_nxviewer()
{
	einfo
	einfo "Building nxviewer"
	einfo

	cd ${S}/server/nxviewer
	# Imakefile needs patching to find the libraries in the right place
	xmkmf -a || die
	emake World || die
}

build_nxspool()
{
	einfo
	einfo "Building nxspool"
	einfo

	cd ${S}/server/nxspool/source
	econf --without-ldap --without-krb5 || die
	# We can't use emake here - it doesn't trigger the right target
	# for some reason
	make || die
}

build_nxsensor()
{
	einfo
	einfo "Building nxsensor"
	einfo

	cd ${S}/server/nxsensor
	emake glib12=1 || die
}

build_nxuexec()
{
	einfo
	einfo "Building nxuexec"
	einfo

	cd ${S}/server/nxuexec
	emake || die
}

build_nxserver()
{
	einfo
	einfo "Building nxserver"
	einfo

	cd ${S}/server/nxnode/src
	./configure || die
	emake setversion || die
	emake || die
}

src_compile()
{
	build_nxagent || die
	build_nxdesktop || die
	build_nxviewer || die
	build_nxspool || die
	build_nxsensor || die
	build_nxuexec || die
	build_nxserver || die
}
