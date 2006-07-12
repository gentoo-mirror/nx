# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit multilib eutils

DESCRIPTION="An X11/RDP/VNC proxy server especially well suited to low bandwidth links such as wireless, WANS, and worse"
HOMEPAGE="http://freenx.berlios.de/"
URI_BASE="http://download.berlios.de/freenx"
SRC_URI="${URI_BASE}/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
RESTRICT="mirror strip"
IUSE="arts cups esd"
DEPEND="virtual/ssh
	dev-tcltk/expect
	sys-apps/gawk
	net-analyzer/gnu-netcat
	!ppc? ( >=net-misc/nxclient-1.5.0
		|| ( ~net-misc/nx-x11-1.5.0
		     ~net-misc/nx-x11-bin-1.5.0
		     ~net-misc/nxnode-2.0.0 ) )
	ppc? ( || ( ~net-misc/nx-x11-1.5.0
		    ~net-misc/nxnode-base-2.0.0 ) )
	arts? ( kde-base/arts )
	cups? ( net-print/cups )"

RDEPEND="${DEPEND}"

S=${WORKDIR}/freenx-0.5.0

pkg_setup () {
	enewuser nx -1 -1 /usr/NX/home/nx
}

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch gentoo-nomachine.diff
	epatch ${FILESDIR}/freenx-xorg7.patch
	epatch ${FILESDIR}/freenx-0.5.0-name-change.patch

	# fix to make sure 32 bit libraries are used by nx-x11 on amd64
	has_multilib_profile && \
		sed -i "/PATH_LIB=/s/lib/$(get_abi_LIBDIR x86)/" nxloadconfig

	# Rename these files so they do not conflict with files installed by nxclient and nxnode.
	mv nxclient nxclient.freenx
	mv nxnode nxnode.freenx
	mv nxprint nxprint.freenx

	# Change the defaults in nxloadconfig to meet the users needs.
	if use arts ; then
		einfo "Enabling arts support."
		sed -i '/ENABLE_ARTSD_PRELOAD=/s/"0"/"1"/' nxloadconfig
		sed -i '/ENABLE_ARTSD_PRELOAD=/s/"0"/"1"/' node.conf.sample
	fi
	if use esd ; then
		einfo "Enabling esd support."
		sed -i '/ENABLE_ESD_PRELOAD=/s/"0"/"1"/' nxloadconfig
		sed -i '/ENABLE_ESD_PRELOAD=/s/"0"/"1"/' node.conf.sample
	fi
	if use cups ; then
		einfo "Enabling cups support."
		sed -i '/ENABLE_KDE_CUPS=/s/"0"/"1"/' nxloadconfig
		sed -i '/ENABLE_KDE_CUPS=/s/"0"/"1"/' node.conf.sample
	fi
}

src_compile() {
	einfo "Nothing to compile"
}

src_install() {

	NX_DIR=/usr/NX
	NX_ETC_DIR=${NX_DIR}/etc
	NX_SESS_DIR=${NX_DIR}/var/db
	NX_HOME_DIR=${NX_DIR}/home/nx

	into ${NX_DIR}
	dobin nxclient.freenx
	dobin nxkeygen
	dobin nxloadconfig
	dobin nxnode.freenx
	dobin nxnode-login
	dobin nxprint.freenx
	dobin nxserver
	dobin nxsetup

	dodir ${NX_ETC_DIR}
	for x in passwords passwords.orig ; do
		touch ${D}${NX_ETC_DIR}/${x}
		chmod 600 ${D}${NX_ETC_DIR}/${x}
	done

	insinto ${NX_ETC_DIR}
	doins node.conf.sample

	ssh-keygen -f ${D}${NX_ETC_DIR}/users.id_dsa -t dsa -N "" -q

	for x in closed running failed ; do
		keepdir ${NX_SESS_DIR}/${x}
		fperms 0700 ${NX_SESS_DIR}/${x}
	done

	dodir ${NX_HOME_DIR}/.ssh
	fperms 0700 ${NX_HOME_DIR}
	fperms 0700 ${NX_HOME_DIR}/.ssh

	cat << EOF >${D}${NX_HOME_DIR}/.ssh/server.id_dsa.pub.key
ssh-dss AAAAB3NzaC1kc3MAAACBAJe/0DNBePG9dYLWq7cJ0SqyRf1iiZN/IbzrmBvgPTZnBa5FT/0Lcj39sRYt1paAlhchwUmwwIiSZaON5JnJOZ6jKkjWIuJ9MdTGfdvtY1aLwDMpxUVoGwEaKWOyin02IPWYSkDQb6cceuG9NfPulS9iuytdx0zIzqvGqfvudtufAAAAFQCwosRXR2QA8OSgFWSO6+kGrRJKiwAAAIEAjgvVNAYWSrnFD+cghyJbyx60AAjKtxZ0r/Pn9k94Qt2rvQoMnGgt/zU0v/y4hzg+g3JNEmO1PdHh/wDPVOxlZ6Hb5F4IQnENaAZ9uTZiFGqhBO1c8Wwjiq/MFZy3jZaidarLJvVs8EeT4mZcWxwm7nIVD4lRU2wQ2lj4aTPcepMAAACANlgcCuA4wrC+3Cic9CFkqiwO/Rn1vk8dvGuEQqFJ6f6LVfPfRTfaQU7TGVLk2CzY4dasrwxJ1f6FsT8DHTNGnxELPKRuLstGrFY/PR7KeafeFZDf+fJ3mbX5nxrld3wi5titTnX+8s4IKv29HJguPvOK/SI7cjzA+SqNfD7qEo8= root@nettuno
EOF
	fperms 0600 ${NX_HOME_DIR}/.ssh/server.id_dsa.pub.key
	cp ${D}${NX_HOME_DIR}/.ssh/server.id_dsa.pub.key ${D}${NX_HOME_DIR}/.ssh/authorized_keys2
	fperms 0600 ${NX_HOME_DIR}/.ssh/authorized_keys2

	echo -n "127.0.0.1" ${D}${NX_HOME_DIR}/.ssh/known_hosts

	chown -R nx:root ${D}${NX_DIR}
}

pkg_postinst () {
	usermod -s /usr/NX/bin/nxserver nx || die "Unable to set login shell of nx user!!"
}
