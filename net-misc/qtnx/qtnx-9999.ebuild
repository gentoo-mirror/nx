# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit qt4 subversion

DESCRIPTION="A Qt-based NX client using nxcl"
HOMEPAGE="http://svn.berlios.de/wsvn/freenx/qtnx"

ESVN_REPO_URI="svn://svn.berlios.de/freenx/trunk/freenx-client/qtnx"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="net-misc/nxcl"
RDEPEND="${DEPEND}"

src_unpack() {
	subversion_src_unpack
	cd "${S}"
	sed -i -e "s#id\.key#/usr/share/${PN}/id.key#" qtnxwindow.cpp || die "sed failed"
}
src_compile() {
	eqmake4
	emake || die "Make failed"
}

src_install() {
	dobin ${PN}
	dodoc README

	insinto /usr/share/${PN}
	doins id.key
}
