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
IUSE="rdesktop vnc"

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

pkg_preinst() {
	enewuser nx -1 -1 /usr/NX/home/nx
}

src_unpack() {
	unpack ${A}
	
	cd ${S}
	epatch ${FILESDIR}/1.5.0/nx-x11-1.5.0-amd64.patch || die
	epatch ${FILESDIR}/1.5.0/nx-x11-1.5.0-plastik-render-fix.patch || die
	epatch ${FILESDIR}/1.5.0/nx-x11-1.5.0-tmp-exec.patch || die
	epatch ${FILESDIR}/1.5.0/nx-x11-1.5.0-xorg7-font-fix.patch || die
	epatch ${FILESDIR}/1.5.0/nx-x11-1.5.0-windows-linux-resume.patch || die
	epatch ${FILESDIR}/1.5.0/nxcompext-1.5.0-insitu.patch || die
	epatch ${FILESDIR}/1.5.0/nxdesktop-1.5.0-insitu.patch || die
	epatch ${FILESDIR}/1.5.0/nxviewer-1.5.0-insitu.patch || die
	epatch ${FILESDIR}/1.5.0/nxsensor-1.5.0-insitu.patch || die
	epatch ${FILESDIR}/1.5.0/nxnode-1.5.0-insitu.patch || die
	epatch ${FILESDIR}/1.5.0/${P}-external-nxcomp.patch || die
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

src_compile() {
	build_nxagent
	if use rdesktop; then
		build_nxdesktop
	fi
	build_nxdesktop
	if use vnc; then
		build_nxviewer
	fi
	build_nxspool
	build_nxsensor
	build_nxuexec
	build_nxserver
}

src_install() {
	# Missing nxnode/nxserver
	into /usr/NX/bin
	dobin ${S}/common/nx-X11/programs/Xserver/hw/nxagent
	dobin ${S}/server/nxsensor/nxsensor
	#TODO: this one should be patched
	dobin ${S}/server/nxnode/setup/nxsetup
	newbin ${S}/server/nxspool/source/bin/smbspool nxspool
	dobin ${S}/server/nxuexec/nxuexec

	if use rdesktop; then
		dobin ${S}/client/nxdesktop/nxdesktop
	fi
	if use vnc; then
		dobin ${S}/server/nxviewer/nxviewer/nxviewer
		dobin ${S}/server/nxviewer/nxpasswd/nxpasswd
	fi

	dodir /usr/NX/lib
	cp -P common/nxcompext/libXcompext.so* ${D}/usr/NX/lib || die
	
	dodir /usr/NX/etc
	#TODO

	into /usr/NX/scripts
	newbin ${S}/server/nxnode/bin/nxnodeenv.sh nxenv.sh
	newbin ${S}/server/nxnode/bin/nxnodeenv.csh nxenv.csh
	into /usr/NX/scripts/restricted
	dobin ${S}/server/nxnode/bin/nxaddinitd.sh
	dobin ${S}/server/nxnode/scripts/nxinit.sh
	newbin ${S}/server/nxnode/bin/nxprinter.sh-LINUX nxprinter.sh
	dobin ${S}/server/nxnode/bin/nxsessreg.sh
	dobin ${S}/server/nxnode/bin/nxuseradd.sh

	cp -R server/nxnode/share ${D}/usr/NX || die
	cp -R home ${D}/usr/NX || die
	#TODO: need to create var?

}

pkg_postinst() {
	usermod -s /usr/NX/bin/nxserver nx || die "Unable to set login shell of nx user!!"
	usermod -d /usr/NX/home/nx nx || die "Unable to set home directory of nx user!!"
	# only run install when no configuration file is found
	#TODO
}
