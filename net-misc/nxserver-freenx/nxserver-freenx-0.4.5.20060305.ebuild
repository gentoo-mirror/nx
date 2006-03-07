# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/nxserver-freenx/nxserver-freenx-0.4.5.ebuild,v 1.1 2005/05/23 19:10:14 stuart Exp $

inherit eutils

DESCRIPTION="An X11/RDP/VNC proxy server especially well suited to low bandwidth links such as ISDN or modem"
HOMEPAGE="http://freenx.berlios.de/"
URI_BASE="http://svn.gnqs.org/downloads/gentoo-nx-overlay"
SRC_URI="$URI_BASE/freenx-${PV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~ppc"
RESTRICT="nomirror strip"
IUSE="commercial"
DEPEND="virtual/ssh
	dev-tcltk/expect
	sys-apps/gawk
	net-analyzer/gnu-netcat
	x86? ( commercial? ( >=net-misc/nxclient-1.4.0 )
	      !commercial? ( !net-misc/nxclient ) )
	!x86? ( !net-misc/nxclient )
	>=net-misc/nxproxy-1.4.0
	>=net-misc/nx-x11-1.4.0
	!net-misc/nxserver-personal
	!net-misc/nxserver-business
	!net-misc/nxserver-enterprise"

S=${WORKDIR}/freenx-${PV}

pkg_setup () {
	enewuser nx -1 -1 /usr/NX/home/nx
}

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch gentoo-nomachine.diff
	epatch $FILESDIR/$PN-0.4.5-xorg7.patch
}

src_compile() {
	einfo "Nothing to compile"
}

src_install() {

	NX_DIR=/usr/NX
	NX_ETC_DIR=$NX_DIR/etc
	NX_SESS_DIR=$NX_DIR/var/db
	NX_HOME_DIR=$NX_DIR/home/nx

	into ${NX_DIR}
	dobin nxserver
	dobin nxnode
	dobin nxnode-login
	dobin nxkeygen
	dobin nxloadconfig
	dobin nxsetup
	( use x86 && use commercial ) || dobin nxprint
	( use x86 && use commercial ) || dobin nxclient

	dodir ${NX_ETC_DIR}
	for x in passwords passwords.orig ; do
		touch ${D}${NX_ETC_DIR}/$x
		chmod 600 ${D}${NX_ETC_DIR}/$x
	done

	insinto ${NX_ETC_DIR}
	doins node.conf.sample

	ssh-keygen -f ${D}${NX_ETC_DIR}/users.id_dsa -t dsa -N "" -q

	for x in closed running failed ; do
		keepdir ${NX_SESS_DIR}/$x
		fperms 0700 ${NX_SESS_DIR}/$x
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
	
	SANDBOX_ON=0

	touch /var/log/nxserver.log
	chown nx /var/log/nxserver.log

	dodir /etc/env.d
	cat << EOF >${D}/etc/env.d/50nxcomp	
PATH=/usr/NX/bin
ROOTPATH=/usr/NX/bin
LDPATH=/usr/NX/lib
CONFIG_PROTECT=/usr/NX/etc	
EOF

	dodir /etc/init.d
	cat << EOF >${D}/etc/init.d/nxserver	
#!/sbin/runscript

depend() {
    use sshd
}

start() {
        einfo "Starting nxserver"
        /usr/NX/bin/nxserver --start >/dev/null
        eend $?
}

stop() {
        einfo "Stopping nxserver"
        /usr/NX/bin/nxserver --stop >/dev/null
        eend $?
}
EOF
	chmod +x /etc/init.d/nxserver
	SANDBOX_ON=1
}

pkg_postinst () {
	usermod -s /usr/NX/bin/nxserver nx || die "Unable to set login shell of nx user!!"

	echo
	einfo "If you are using NX version 1.5.0, make sure you edit the file:"
	einfo "/usr/NX/etc/node.conf and set ENABLE_1_5_0_BACKEND to 1."
	echo
	einfo "Init script /etc/init.d/nxserver created. Remember to add"
	einfo "nxserver to default runlevel if you want it to start at boot:"
	einfo "		rc-update add nxserver default"
	echo
}
