# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit rpm

DESCRIPTION="NXClient is a X11/VNC/NXServer client especially tuned for using remote desktops over low-bandwidth links such as the Internet"
HOMEPAGE="http://www.nomachine.com"

IUSE=""
LICENSE="as-is"
SLOT="0"
KEYWORDS="-alpha ~amd64 -mips -ppc -sparc ~x86"
RESTRICT="nostrip"

SRC_URI="http://web04.nomachine.com/download/1.5.0/client/$P-141.i386.rpm"

DEPEND="
	~net-misc/nxssh-1.5.0
	~net-misc/nxesd-1.5.0
	net-analyzer/gnu-netcat
	amd64? (
		app-emulation/emul-linux-x86-compat
		>=app-emulation/emul-linux-x86-baselibs-2.1.4
		>=app-emulation/emul-linux-x86-xlibs-2.2.1
		>=app-emulation/emul-linux-x86-qtlibs-2.1.1
	)
	x86? (
		>=dev-libs/expat-1.95.7
		>=media-libs/fontconfig-2.2.2
		>=media-libs/freetype-2.1.9
		>=x11-libs/qt-3.3.4
		sys-libs/lib-compat
	)"

S=${WORKDIR}

src_install() {
	# rpm has usr/NX/; tarball has only NX/
	if [[ ! -d usr ]]; then
		mkdir usr
		mv NX usr || die
	fi

	cp -dPR usr ${D}

	# All of the libraries delivered by nxclient are available in our deps.
	# Additionally a couple of the binaries are better installed as deps.
	# Remove those now...

	# delivered by net-misc/nxcomp
	rm -f ${D}/usr/NX/lib/libXcomp.so*

	# delivered by net-misc/nxesd
	rm -f ${D}/usr/NX/bin/nxesd

	# delivered by net-misc/nxssh
	rm -f ${D}/usr/NX/bin/nxssh

	# delivered by other deps (emul-linux-x86-baselibs on amd64)
	rm -f ${D}/usr/NX/lib/lib{crypto,jpeg,png,z}*

	# make sure there are no libs left (this is to catch problems when this
	# package is updated)
	rmdir ${D}/usr/NX/lib || die "leftover libraries in ${D}/usr/NX/lib"

	# FIXME: Of the options in the applnk directory, the desktop files in the
	# "network" directory seem to make the most sense.  I have no idea if this
	# works for KDE or just for Gnome.
	declare applnk=/usr/NX/share/applnk apps=/usr/share/applications
	if [[ -d ${D}${applnk} ]]; then
		dodir ${apps}
		mv ${D}${applnk}/network/*.desktop ${D}${apps}
		rm ${D}${apps}/nxclient-help.desktop
		rm -rf ${D}${applnk}
	fi
}