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

DEPEND="
	dev-libs/glib
	dev-libs/openssl
	dev-perl/BSD-Resource
	dev-perl/GDGraph
	dev-perl/Passwd-Linux
	dev-perl/Unix-Syslog
	media-libs/jpeg
	media-libs/libpng
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
	epatch ${FILESDIR}/1.5.0/${P}-setup.patch || die

	# Set correct product name (until proper tarballs are available)
	einfo "Setting correct product name (this will take some time)"
	find . -type f -exec sed -i "s/@PRODUCT_NAME@/2X TerminalServer/g" {} \;
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
	make setversion
	make nxnode.pl nxserver.pl || die
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
	into /usr/NX
	dobin ${S}/common/nx-X11/programs/Xserver/nxagent
	dobin ${S}/server/nxsensor/nxsensor
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

	dobin ${S}/server/nxnode/src/nxnode.pl
	dobin ${S}/server/nxnode/src/nxserver.pl

	make_wrapper nxnode "perl -I/usr/NX/lib/perl /usr/NX/bin/nxnode.pl" /usr/NX/bin /usr/NX/lib /usr/NX/bin
	make_wrapper nxserver "perl -I/usr/NX/lib/perl /usr/NX/bin/nxserver.pl" /usr/NX/bin /usr/NX/lib /usr/NX/bin

	dodir /usr/NX/lib/perl
	cd ${S}/server/nxnode/src
	cp -RH *.pm Config Exception NXShellDialogs handlers nxstat ${D}/usr/NX/lib/perl || die
	dodir /usr/NX/etc/keys
	perl MakeConfigFile.pl DEBIAN > ${D}/usr/NX/etc/node-gentoo.cfg.sample
	for x in passwords users administrators; do
		cp ../etc/${x} ${D}/usr/NX/etc/${x}.db.sample
	done
	
	cd ${S}
	cp -P common/nxcompext/libXcompext.so* \
		common/nx-X11/lib/X11/libX11.so* ${D}/usr/NX/lib || die

	exeinto /usr/NX/scripts
	newexe ${S}/server/nxnode/bin/nxnodeenv.sh nxenv.sh
	newexe ${S}/server/nxnode/bin/nxnodeenv.csh nxenv.csh
	exeinto /usr/NX/scripts/restricted
	doexe ${S}/server/nxnode/bin/nxaddinitd.sh
	doexe ${S}/server/nxnode/scripts/nxinit.sh
	newexe ${S}/server/nxnode/bin/nxprinter.sh-LINUX nxprinter.sh
	doexe ${S}/server/nxnode/bin/nxsessreg.sh
	doexe ${S}/server/nxnode/bin/nxuseradd.sh

	cp -R server/nxnode/share ${D}/usr/NX || die
	cp -R server/nxnode/home ${D}/usr/NX || die
	dodir /usr/NX/var/log
	dodir /usr/NX/var/run
	dodir /usr/NX/var/db/closed
	dodir /usr/NX/var/db/failed
	dodir /usr/NX/var/db/nxstat
	dodir /usr/NX/var/db/running
}

pkg_postinst() {
	usermod -s /usr/NX/bin/nxserver nx || die "Unable to set login shell of nx user!!"
	usermod -d /usr/NX/home/nx nx || die "Unable to set home directory of nx user!!"
	# only run install when no configuration file is found
	if [ -f /usr/NX/etc/node.cfg ]; then
		einfo "Running 2X update script"
		${ROOT}/usr/NX/bin/nxsetup --update
	else
		einfo "Running 2X setup script"
		${ROOT}/usr/NX/bin/nxsetup --install
	fi
}
