# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit autotools subversion

DESCRIPTION="A library for building NX clients"
HOMEPAGE="http://svn.berlios.de/wsvn/freenx/nxcl"

ESVN_REPO_URI="svn://svn.berlios.de/freenx/nxcl"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="dbus"

DEPEND="dbus? ( sys-apps/dbus )
	net-misc/nx"
RDEPEND="${DEPEND}"

src_unpack() {
	subversion_src_unpack
	eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
}
