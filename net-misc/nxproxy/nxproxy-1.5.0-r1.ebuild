# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/nxproxy/nxproxy-1.4.0-r2.ebuild,v 1.3 2005/05/23 18:41:11 stuart Exp $

inherit eutils

DESCRIPTION="X11 protocol compression library wrapper"
HOMEPAGE="http://www.nomachine.com/"

IUSE=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~ppc"

SRC_NXPROXY="nxproxy-$PV-9.tar.gz"
SRC_NXCOMP="nxcomp-$PV-80.tar.gz"
URI_BASE="http://64.34.161.181/download/1.5.0/sources"
SRC_URI="$URI_BASE/$SRC_NXPROXY
	 $URI_BASE/$SRC_NXCOMP"

DEPEND="=net-misc/nx-x11-1.5*
	sys-devel/patch
	>=media-libs/jpeg-6b-r3
	>=sys-libs/glibc-2.3.2-r1
	>=sys-libs/zlib-1.1.4-r1"

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${SRC_NXPROXY}
	unpack ${SRC_NXCOMP}

	cd "${S}/../nxcomp"

	epatch ${FILESDIR}/1.5.0/nxcomp-pic.patch
	epatch ${FILESDIR}/1.5.0/nxcomp-gcc4.patch
}

src_compile() {

	cd ../nxcomp
	econf --prefix="/usr/NX/" || die "Unable to configure nxcomp"
	emake || die "Unable to build nxcomp"

	cd ../nxproxy
	./configure

	emake || die "compile problem"
}

src_install() {
	into /usr/NX
	dobin nxproxy
	dodoc README README-IPAQ README-VALGRIND VERSION LICENSE
}
