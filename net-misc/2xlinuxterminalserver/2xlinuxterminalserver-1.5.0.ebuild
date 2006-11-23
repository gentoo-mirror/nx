# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION=""
HOMEPAGE=""
SRC_URI="http://code.2x.com/release/linuxterminalserver/src/linuxterminalserver-1.5.0-r21-src.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND="
	dev-libs/glib
	dev-libs/openssl
	dev-perl/BSD-Resource
	dev-perl/Data-Dumper
	dev-perl/DBD-SQLite
	dev-perl/DBI
	dev-perl/Digest-MD5
	dev-perl/Error
	dev-perl/GD
	dev-perl/GDGraph
	dev-perl/GDTextUtil
	dev-perl/Passwd-Linux
	dev-perl/Tie-IxHash
	perl-core/Time-HiRes
	dev-perl/Unix-Syslog
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
	unpack ${A}
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
}

# ------------------------------------------------------------------------
# Functions to build single parts of 2xlinuxterminalserver
#
# These functions follow the same naming convention that 2X's build
# script uses, to make it easy for us to compare what we do with what
# they do

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

	cd ${S}/server/nxspool || die
	./configure --without-ldap --without-krb5 || die
	emake || die
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
