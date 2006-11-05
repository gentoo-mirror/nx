# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION=""
HOMEPAGE="http://www.nomachine.com/"
SRC_URI="http://64.34.161.181/download/2.1.0/Linux/FE/nxserver-2.1.0-9.i386.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND="
	=net-misc/nxnode-2.1*
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/NX"

pkg_preinst()
{
	enewuser nx -1 -1 /usr/NX/home/nx || die
}

src_unpack()
{
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/nxserver-2.1.0-setup.patch || die
}

src_install()
{
	cd ${S}

	# we install nxserver into /usr/NX, to make sure it doesn't clash
	# with libraries installed for FreeNX

	into /usr/NX
	for x in nxserver ; do
		dobin bin/$x || die
	done

	dodir /usr/NX/etc
	insinto /usr/NX/etc
	doins etc/administrators.db.sample || die
	doins etc/guests.db.sample || die
	doins etc/passwords.db.sample || die
	doins etc/profiles.db.sample || die
	doins etc/users.db.sample || die

	newins etc/server-debian.cfg.sample server-gentoo.cfg.sample || die
	newins etc/server.lic.sample server.lic || die

	cp -R etc/keys ${D}/usr/NX/etc || die

	cp -R home ${D}/usr/NX || die
	cp -R lib ${D}/usr/NX || die
	cp -R scripts ${D}/usr/NX || die
	cp -R share ${D}/usr/NX || die
	cp -R var ${D}/usr/NX || die

	exeinto /etc/init.d
	newexe ${FILESDIR}/nxserver-2.1.0-init nxserver || die
}

pkg_postinst ()
{
	usermod -d /usr/NX/home/nx nx || die

	einfo "Running NoMachine's setup script"
	${ROOT}/usr/NX/scripts/setup/nxserver --install

	elog "Remember to add nxserver to your default runlevel"
}
