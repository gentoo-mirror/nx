# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/nxserver-freenx/nxserver-freenx-0.5.0.20060311-r1.ebuild,v 1.1 2006/04/30 19:38:46 stuart Exp $

inherit multilib eutils rpm

DESCRIPTION="An X11/RDP/VNC proxy server especially well suited to low bandwidth links such as wireless, WANS, and worse"
HOMEPAGE="http://freenx.berlios.de/"
SRC_URI="ftp://ftp.pbone.net/mirror/download.fedora.redhat.com/pub/fedora/linux/extras/5/i386/freenx-0.5.0-5.fc5.i386.rpm"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
RESTRICT="strip"
IUSE="arts cups esd nxclient"
DEPEND="virtual/ssh
	dev-tcltk/expect
	sys-apps/gawk
	net-analyzer/gnu-netcat
	x86? ( nxclient? ( =net-misc/nxclient-1.5* )
	      !nxclient? ( !net-misc/nxclient ) )
	amd64? ( nxclient? ( =net-misc/nxclient-1.5* )
	        !nxclient? ( !net-misc/nxclient ) )
	!x86? ( !amd64? ( !net-misc/nxclient ) )
	|| ( =net-misc/nx-x11-1.5*
	     =net-misc/nx-x11-bin-1.5* )
	arts? ( kde-base/arts )
	cups? ( net-print/cups )
	esd? ( media-sound/esound )
	!net-misc/nxserver-personal
	!net-misc/nxserver-business
	!net-misc/nxserver-enterprise"

RDEPEND="${DEPEND}"

S=${WORKDIR}

export NX_HOME_DIR=/var/lib/nxserver/home

pkg_setup () {
	enewuser nx -1 -1 ${NX_HOME_DIR}
}

src_unpack() {
	rpm_unpack ${DISTDIR}/${A}
	cd ${S}

	mv etc/nxserver/node.conf.sample etc/nxserver/node.conf

	# fix to make sure 32 bit libraries are used by nx-x11 on amd64
	has_multilib_profile && \
		sed -i "/PATH_LIB=/s/lib/$(get_abi_LIBDIR x86)/" usr/bin/nxloadconfig

	# Change the defaults in nxloadconfig to meet the users needs.
	if use arts ; then
		einfo "Enabling arts support."
		sed -i '/ENABLE_ARTSD_PRELOAD=/s/"0"/"1"/' usr/bin/nxloadconfig
		sed -i '/ENABLE_ARTSD_PRELOAD=/s/"0"/"1"/' etc/nxserver/node.conf
	fi
	if use esd ; then
		einfo "Enabling esd support."
		sed -i '/ENABLE_ESD_PRELOAD=/s/"0"/"1"/' usr/bin/nxloadconfig
		sed -i '/ENABLE_ESD_PRELOAD=/s/"0"/"1"/' etc/nxserver/node.conf
	fi
	if use cups ; then
		einfo "Enabling cups support."
		sed -i '/ENABLE_KDE_CUPS=/s/"0"/"1"/' usr/bin/nxloadconfig
		sed -i '/ENABLE_KDE_CUPS=/s/"0"/"1"/' etc/nxserver/node.conf
	fi
}

src_compile() {
	einfo "Nothing to compile"
}

src_install() {
	NX_ETC_DIR=/etc/nxserver
	NX_SESS_DIR=/var/lib/nxserver/db
	
	dobin usr/bin/nxserver
	dobin usr/bin/nxnode
	dobin usr/bin/nxnode-login
	dobin usr/bin/nxkeygen
	dobin usr/bin/nxloadconfig
	dobin usr/bin/nxsetup
	( ( use x86 || use amd64 ) && use nxclient ) || dobin usr/bin/nxprint
	( ( use x86 || use amd64 ) && use nxclient ) || dobin usr/bin/nxclient

	dodir ${NX_ETC_DIR}
	for x in passwords passwords.orig ; do
		touch ${D}${NX_ETC_DIR}/$x
		chmod 600 ${D}${NX_ETC_DIR}/$x
	done

	insinto ${NX_ETC_DIR}
	doins etc/nxserver/node.conf

	dodir ${NX_HOME_DIR}

	# ssh-keygen -f ${D}${NX_ETC_DIR}/users.id_dsa -t dsa -N "" -q

	for x in closed running failed ; do
		keepdir ${NX_SESS_DIR}/$x
		fperms 0700 ${NX_SESS_DIR}/$x
	done

	#dodir ${NX_HOME_DIR}/.ssh
	#fperms 0700 ${NX_HOME_DIR}
	#fperms 0700 ${NX_HOME_DIR}/.ssh

	#cat << EOF >${D}${NX_HOME_DIR}/.ssh/server.id_dsa.pub.key
#ssh-dss AAAAB3NzaC1kc3MAAACBAJe/0DNBePG9dYLWq7cJ0SqyRf1iiZN/IbzrmBvgPTZnBa5FT/0Lcj39sRYt1paAlhchwUmwwIiSZaON5JnJOZ6jKkjWIuJ9MdTGfdvtY1aLwDMpxUVoGwEaKWOyin02IPWYSkDQb6cceuG9NfPulS9iuytdx0zIzqvGqfvudtufAAAAFQCwosRXR2QA8OSgFWSO6+kGrRJKiwAAAIEAjgvVNAYWSrnFD+cghyJbyx60AAjKtxZ0r/Pn9k94Qt2rvQoMnGgt/zU0v/y4hzg+g3JNEmO1PdHh/wDPVOxlZ6Hb5F4IQnENaAZ9uTZiFGqhBO1c8Wwjiq/MFZy3jZaidarLJvVs8EeT4mZcWxwm7nIVD4lRU2wQ2lj4aTPcepMAAACANlgcCuA4wrC+3Cic9CFkqiwO/Rn1vk8dvGuEQqFJ6f6LVfPfRTfaQU7TGVLk2CzY4dasrwxJ1f6FsT8DHTNGnxELPKRuLstGrFY/PR7KeafeFZDf+fJ3mbX5nxrld3wi5titTnX+8s4IKv29HJguPvOK/SI7cjzA+SqNfD7qEo8= root@nettuno
#EOF
	#fperms 0600 ${NX_HOME_DIR}/.ssh/server.id_dsa.pub.key
	#cp ${D}${NX_HOME_DIR}/.ssh/server.id_dsa.pub.key ${D}${NX_HOME_DIR}/.ssh/authorized_keys2
	#fperms 0600 ${NX_HOME_DIR}/.ssh/authorized_keys2

	#echo -n "127.0.0.1" ${D}${NX_HOME_DIR}/.ssh/known_hosts

	#chown -R nx:root ${D}${NX_DIR}
}

pkg_postinst () {
	usermod -s /usr/bin/nxserver nx || die "Unable to set login shell of nx user!!"
}
