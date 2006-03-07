# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/nxssh/nxssh-1.5.0-r1.ebuild,v 1.2 2005/10/20 21:54:54 agriffis Exp $

inherit eutils

DESCRIPTION="Modified openssh client, used by nxclient"
HOMEPAGE="http://www.nomachine.com/"

SRC_NXSSH="nxssh-$PV-23.tar.gz"
SRC_NXCOMP="nxcomp-$PV-80.tar.gz"
URI_BASE="http://web04.nomachine.com/download/1.5.0/sources"
SRC_URI="$URI_BASE/$SRC_NXSSH
	 $URI_BASE/$SRC_NXCOMP"

IUSE="ipv6 pam tcpd"
LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~ppc"

DEPEND="dev-libs/openssl
	virtual/libc
	sys-libs/zlib
	tcpd? ( sys-apps/tcp-wrappers )
	pam? ( sys-libs/pam )"

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${SRC_NXSSH}
	unpack ${SRC_NXCOMP}

	cd "${S}/../nxcomp"

	epatch ${FILESDIR}/1.5.0/nxcomp-pic.patch
	epatch ${FILESDIR}/1.5.0/nxcomp-gcc4.patch
}

src_compile() {

	cd ../nxcomp
	econf --prefix="/usr/NX/" || die "Unable to configure nxcomp"
	emake || die "Unable to build nxcomp"

	cd ../nxssh
			
	./configure \
	    --prefix=/usr \
		--sysconfdir=/etc/ssh \
		--mandir=/usr/share/man \
		--libexecdir=/usr/lib/misc \
		--datadir=/usr/share/openssh \
		--disable-suid-ssh \
		--with-privsep-path=/var/empty \
		--with-privsep-user=sshd \
		--with-md5-passwords \
		$(use_with tcpd tcp-wrappers) \
		$(use_with pam) \
		$(use_with !ipv6 ipv4-default) \
		|| die "configure nxssh failed"
	emake || die "emake nxssh failed"
}

src_install() {
	into /usr/NX
	dobin nxssh
}
