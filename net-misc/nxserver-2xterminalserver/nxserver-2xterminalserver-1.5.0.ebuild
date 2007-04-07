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
	epatch ${FILESDIR}/1.5.0/${P}-insitu.patch || die
	epatch ${FILESDIR}/1.5.0/${P}-external-nxcomp.patch || die
	epatch ${FILESDIR}/1.5.0/${P}-setup.patch || die
	sed -i 's/-Wnested-externs/-Wnested-externs -fPIC/' \
		common/nxcompext/Makefile.in || die "sed failed"

	# Set correct product name (until proper tarballs are available)
	einfo "Setting correct product name (this will take some time)"
	find . -type f -exec sed -i "s/@PRODUCT_NAME@/2X TerminalServer/g" {} \;
}

src_compile() {
	cd ${S}/common/nxcompext
	append-ldflags "-L/usr/NX/lib"
	econf || die
	emake || die

	cd ${S}/common/nx-X11
	emake World || die

	if use rdesktop; then
		cd ${S}/client/nxdesktop
		CC=(tc-getCC) ./configure || die
		emake || die
	fi

	if use vnc; then
		cd ${S}/server/nxviewer
		xmkmf -a || die
		emake World || die
	fi

	cd ${S}/server/nxspool/source
	econf --without-ldap --without-krb5 || die
	# We can't use emake here - it doesn't trigger the right target
	# for some reason
	make || die

	cd ${S}/server/nxsensor
	emake glib12=1 || die

	cd ${S}/server/nxuexec
	emake || die

	cd ${S}/server/nxnode/src
	./configure || die
	make setversion
	make nxnode.pl nxserver.pl || die
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
	# Workaround fonts link
	if has_version '>=x11-base/xorg-x11-7.0' && ! [ -e /usr/lib/X11/fonts ];
	then
		ln -s /usr/share/fonts /usr/lib/X11/fonts
	fi

	# only run install when no configuration file is found
	if [ -f /usr/NX/etc/node.cfg ]; then
		einfo "Running 2X update script"
		${ROOT}/usr/NX/bin/nxsetup --update
	else
		einfo "Running 2X setup script"
		${ROOT}/usr/NX/bin/nxsetup --install
	fi
}
