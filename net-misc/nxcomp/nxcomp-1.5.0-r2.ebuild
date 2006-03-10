# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils multilib

DESCRIPTION="X11 protocol compression library"
HOMEPAGE="http://www.nomachine.com/"

IUSE=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"

SRC_URI="http://web04.nomachine.com/download/1.5.0/sources/$P-80.tar.gz"

DEPEND="media-libs/jpeg
	media-libs/libpng
	virtual/libc
	sys-libs/zlib
	virtual/x11"

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	epatch ${FILESDIR}/nxcomp-1.5.0-r1-pic.patch
	epatch ${FILESDIR}/nxcomp-1.5.0-r1-gcc4.patch
}

src_compile() {
	econf
	emake || die "emake failed"
}

src_install() {
	into /usr/NX
	dolib libXcomp.so*
	if [[ $(get_libdir) != lib ]]; then
		# necessary for nxclient to work, it seems
		ln -s "$(get_libdir)" ${D}/usr/NX/lib
	fi

	preplib /usr/NX/lib

	insinto /usr/NX/include
	doins NX*.h MD5.h

	insinto /usr/X11R6/include
	doins NX.h

	dodoc README README-IPAQ LICENSE VERSION

	# environment variables
	cat <<EOF > ${T}/50nxpaths
PATH=/usr/NX/bin
ROOTPATH=/usr/NX/bin
LDPATH=/usr/NX/lib
EOF
	insinto /etc/env.d
	doins ${T}/50nxpaths
}
