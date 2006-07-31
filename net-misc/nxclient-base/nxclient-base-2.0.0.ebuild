# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="A special version of the X11 libraries supporting NX compression technology"
HOMEPAGE="http://www.nomachine.com/developers.php"

URI_BASE="http://web04.nomachine.com/download/2.0.0/sources"
SRC_NXCOMP="nxcomp-$PV-81.tar.gz"
SRC_NXCOMPSH="nxcompsh-$PV-5.tar.gz"
SRC_NXESD="nxesd-$PV-4.tar.gz"
SRC_NXKILL="nxkill-$PV-4.tar.gz"
SRC_NXSERVICE="nxservice-$PV-26.tar.gz"
SRC_NXSSH="nxssh-$PV-12.tar.gz"

SRC_URI="$URI_BASE/$SRC_NXCOMP $URI_BASE/$SRC_NXCOMPSH
	$URI_BASE/$SRC_NXKILL $URI_BASE/$SRC_NXSERVICE $URI_BASE/$SRC_NXSSH
	esd? ( $URI_BASE/$SRC_NXESD )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-amd64 ~ppc ~x86"
RESTRICT="mirror"
IUSE="alsa debug esd ipv6 pam tcpd"

DEPEND=">=media-libs/jpeg-6b-r7
	>=media-libs/libpng-1.2.8
	net-analyzer/gnu-netcat
	>=sys-libs/zlib-1.2.3
	>=dev-libs/openssl-0.9.7

	tcpd? ( >=sys-apps/tcp-wrappers-7.6 )
	pam? ( >=sys-libs/pam-0.77 )

	esd? ( >=media-libs/audiofile-0.2.6
	       >=media-sound/esound-0.2.36
	       alsa? ( >=media-libs/alsa-lib-0.5.10b ) )

	amd64? (
		app-emulation/emul-linux-x86-compat
		>=app-emulation/emul-linux-x86-baselibs-2.1.4
	       )

	x86? ( >=sys-libs/lib-compat-1.4 )

	|| ( app-text/rman
	     virtual/x11 )"

RDEPEND="${DEPEND}
	!net-misc/nx-x11
	!net-misc/nx-x11-bin
	!net-misc/nxcomp
	!net-misc/nxesd
	!net-misc/nxproxy
	!net-misc/nxserver-business
	!net-misc/nxserver-enterprise
	!net-misc/nxserver-personal
	!net-misc/nxssh"

S=${WORKDIR}

src_unpack() {
	# we can't use ${A} because of bug #61977
	unpack ${SRC_NXCOMP}
	unpack ${SRC_NXCOMPSH}
	unpack ${SRC_NXKILL}
	unpack ${SRC_NXSERVICE}
	unpack ${SRC_NXSSH}
	use esd && unpack ${SRC_NXESD}

	cd ${S}
	epatch ${FILESDIR}/2.0.0/nxcomp-2.0.0-makefile.patch
	epatch ${FILESDIR}/2.0.0/nxcompsh-2.0.0-makefile.patch
	epatch ${FILESDIR}/2.0.0/nxkill-2.0.0-makefile.patch
	epatch ${FILESDIR}/2.0.0/nxservice-2.0.0-makefile.patch
}

src_compile() {
	cd nxcomp
	econf --prefix="/usr/NX/" || die "Unable to configure nxcomp"
	emake || die "emake for nxcomp failed"

	cd ../nxcompsh
	econf --prefix="/usr/NX/" || die "Unable to configure nxcompsh"
	emake || die "emake for nxcompsh failed"

	cd ../nxkill
	econf --prefix="/usr/NX/" || die "Unable to configure nxkill"
	emake || die "emake for nxkill failed"

	cd ../nxservice
	econf --prefix="/usr/NX/" || die "Unable to configure nxservice"
	emake || die "emake for nxservice failed"

	cd ../nxssh
	econf --prefix="/usr/NX/" \
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
		|| die "Unable to configure nxssh"
	emake || die "emake for nxssh failed"

	if use esd ; then
		cd ../nxesd
		econf --prefix=/usr/NX --sysconfdir=/etc/esd \
			$(use_enable ipv6) $(use_enable debug debugging) \
			$(use_enable alsa) $(use_with tcpd libwrap) \
			|| die "configure nxssh failed"
		emake || die "emake nxssh failed"
	fi
}

src_install() {
	into /usr/NX

	dobin nxkill/nxkill

	# Make wrappers to /usr/NX/lib, so other programs are not affected.
	newbin nxservice/nxservice nxservice.bin
	make_wrapper nxservice nxservice.bin /usr/NX/bin /usr/NX/lib /usr/NX/bin
	newbin nxssh/nxssh nxssh.bin
	make_wrapper nxssh nxssh.bin /usr/NX/bin /usr/NX/lib /usr/NX/bin

	if use esd ; then
		dobin nxesd/nxesd
	fi

	dolib.so nxcomp/libXcomp.so*
	dolib.so nxcompsh/libXcompsh.so*

	insinto /usr/NX/include
	doins nxcomp/NX*.h nxcomp/MD5.h

	# install environment variables
	cat <<EOF > ${T}/50nxpaths
NXDIR=/usr/NX
PATH=\${NXDIR}/bin
ROOTPATH=\${NXDIR}/bin
CONFIG_PROTECT="\${NXDIR}/etc \${NXDIR}/home"
PRELINK_PATH_MASK=\${NXDIR}
SEARCH_DIRS_MASK=\${NXDIR}
EOF
	doenvd ${T}/50nxpaths
}
