# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="A X11/RDP/VNC proxy server especially well suited to low bandwidth
links such as wireless, WANS, and worse"
HOMEPAGE="http://www.2x.com/terminalserver/"
SRC_URI="http://code.2x.com/release/linuxterminalserver/src/linuxterminalserver-1.5.0-r21-src.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND="
	dev-libs/glib
	dev-libs/openssl
	media-libs/gd
	media-libs/jpeg
	media-libs/libpng
	net-print/cups
	sys-libs/zlib
	=x11-libs/qt-3*"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_unpack()
{
	# step 1 - unpack the main tarball
	unpack ${A}

	# step 2 - unpack the bundled perl + additional modules
	#
	# NOTE - we cannot use unpack here because it incorrectly reports
	#        these tar files as not existing
	# cd ${S}/components
	# tar -zxf perl-5.6.2.tar.gz || die
	# tar -zxf BSD-Resource-1.23.tar.gz || die
	# tar -zxf Data-Dumper-2.121.tar.gz || die
	# tar -zxf DateManip-5.42a.tar.gz || die
	# tar -zxf DBD-SQLite-1.07.tar.gz || die
	# tar -zxf DBI-1.45.tar.gz || die
	# tar -zxf Digest-MD5-2.33.tar.gz || die
	# tar -zxf Error-0.15.tar.gz || die
	# tar -zxf GD-2.19.tar.gz || die
	# tar -zxf GDGraph-1.43.tar.gz || die
	# tar -zxf GDTextUtil-0.86.tar.gz || die
	# tar -zxf Passwd-Linux-0.70.tar.gz || die
	# tar -zxf Tie-IxHash-1.21.tar.gz || die
	# tar -zxf Time-HiRes-1.68.tar.gz || die
	# tar -zxf Unix-Syslog-0.99.tar.gz || die

	# step 3 - apply patches
	cd ${S}
	epatch ${FILESDIR}/1.5.0/nxcomp-1.5.0-gcc4.patch || die
	epatch ${FILESDIR}/1.5.0/nxcomp-1.5.0-pic.patch || die
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
}

# ------------------------------------------------------------------------
# Functions to build single parts of 2xlinuxterminalserver
#
# These functions follow the same naming convention that 2X's build
# script uses, to make it easy for us to compare what we do with what
# they do

build_perl()
{
	einfo
	einfo "Building perl"
	einfo

	cd ${S}/components/perl-5.6.2 || die
	./Configure -des -Uafs -Ud_csh -Duseshrplib -Dprefix="${S}/perl" -Uuse5005threads -Uusethreads -Ui_db -Ui_gdbm _Ui_ndbm -Ui_dbm -Ui_sdbm -Duseopcode || die
	make || die

	# we have to install at this stage, because we need to use this copy
	# of perl to build other components
	#
	# I will be much happier when we can use the system Perl instance
	make install || die
}

build_nxcomp()
{
	einfo
	einfo "Building nxcomp"
	einfo

	cd ${S}/common/nxcomp || die
	./configure || die
	emake || die
}

build_nxssh()
{
	einfo
	einfo "Building nxssh"
	einfo

	cd ${S}/common/nxssh || die
	./configure || die
	emake || die
}

build_nxesd()
{
	einfo
	einfo "Building nxesd"
	einfo

	cd ${S}/client/nxesd || die
	./configure || die
	emake || die
}

build_qt_libraries_and_client()
{
	# we do not need to build qt ... it is installed as part of the system
	# we do not need to build cups ... it is installed as part of the system

	einfo
	einfo "Building nxclient"
	einfo

	cd ${S}/client/nxclient || die
	./configure || die
	emake || die

	einfo
	einfo "Building nxprint"
	einfo

	cd ${S}/client/nxclient/nxprint || die
	emake || die
}

build_nxagent()
{
	einfo
	einfo "Building nx-X11"
	einfo

	cd ${S}/common/nx-X11 || die
	emake World || die

	einfo
	einfo "Building nxcompext"
	einfo

	cd ${S}/common/nxcompext || die
	emake || die
}

build_nxdesktop()
{
	einfo
	einfo "Building nxdesktop"
	einfo

	cd ${S}/client/nxdesktop || die
	./configure || die
	sed -e 's|/usr/X11R6/lib|../../common/nx-X11/lib/X11|g;' -i Makeconf || die
	sed -e 's|/usr/X11R6/include|../../common/nx-X11/lib/X11|g;' -i Makeconf || die
	emake || die
}

build_nxviewer()
{
	einfo
	einfo "Building nxviewer"
	einfo

	cd ${S}/server/nxviewer || die
	xmkmf || die

	# Imakefile needs patching to find the libraries in the right place

	emake World || die
}

build_nxspool()
{
	einfo
	einfo "Building nxspool"
	einfo

	cd ${S}/server/nxspool/source || die
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

	cd ${S}/server/nxsensor || die
	emake glib12=1 || die
}

build_nxuexec()
{
	einfo
	einfo "Building nxuexec"
	einfo

	cd ${S}/server/nxuexec || die
	emake || die
}

build_nxserver()
{
	einfo
	einfo "Building nxserver"
	einfo

	cd ${S}/server/nxnode/src || die
	./configure || die
	emake setversion || die
	emake || die
}

build_client()
{
	build_nxcomp || die
	build_nxssh || die
	build_nxesd || die
	build_qt_libraries_and_client || die
	build_nxagent || die
	build_nxdesktop || die
}

build_server()
{
	build_nxviewer || die
	build_nxspool || die
	build_nxsensor || die
	build_nxuexec || die
	build_nxserver || die
}

src_compile()
{
	build_client || die
	build_server || die
}
