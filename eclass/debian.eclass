# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# Author : Jonathan Scruggs <j.scruggs@gmail.com> (09 April 2006)
# Based on rpm.eclass by : Alastair Tse <liquidx@gentoo.org> (21 Jun 2003)
#
# Convienence class for extracting DEBs
#
# Basically, deb_src_unpack does:
#
# 1. uses debian_unpack to unpack a deb file using ar from binutils.
# 2. deletes all the unpacked tarballs and zip files from ${WORKDIR}
# NOTE: deb2targz requiers perl, and that is not a package installed
#       by default. ar comes with binutils, so everyone should have
#       this already, and no need for a dependency of a really large
#       package like perl. Some users may never need perl.
#
# This ebuild now re-defines a utility function called deb_unpack which
# basically extracts the files out of the deb. It does not gzip the
# output tar again but directly extracts to ${WORKDIR}
#
# I don't know if this will handle RPMs in the list, but it will with
# other regular files that the unpack command can handle. :)


# extracts the contents of the DEP in ${WORKDIR}
debian_unpack() {
	local debfile return_value
	debfile=$1

	if [ -z "${debfile}" ]; then
		return_value=1
	else
		ar x ${debfile}
		# remove unneeded files.
		rm -f control.tar.gz debian-binary

		# Make this multi-file friendly.
		# Keeps file for debugging purpose in temporary distdir.
		# This will be deleted once the package installs successfully
		mv data.tar.gz ${debfile//.deb/.tar.gz}

		return_value=0
	fi

	return ${return_value}
}

debian_src_unpack() {
	local x ext myfail OLD_DISTDIR

	for x in ${A}; do
		myfail="failure unpacking ${x}"
		ext=${x##*.}
		case "$ext" in
		deb)
			echo ">>> Unpacking ${x}"
			cd ${WORKDIR}
			debian_unpack ${DISTDIR}/${x} || die "${myfail}"

			unpack ${x//.deb/.tar.gz}
			;;
		*)
			unpack ${x}
			;;
		esac
	done
}

EXPORT_FUNCTIONS src_unpack
