# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit distutils versionator

MAJOR_PV="$(get_version_component_range 1-3)"
PATCH_VER="$(get_version_component_range 4)"

DESCRIPTION="GTK FreeNX client"
HOMEPAGE="https://code.launchpad.net/~freenx-team/freenx-server/eagleeye"
SRC_URI="https://launchpad.net/~marceloshima/+archive/tacix/+files/${PN}_${MAJOR_PV}+ubuntubzr${PATCH_VER/p}~jaunty-1.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-python/pygtk"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${PN}-${MAJOR_PV}+ubuntubzr${PATCH_VER/p}~jaunty
