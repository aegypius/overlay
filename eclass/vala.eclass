# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: vala.eclass
# @MAINTAINER:
# Gavrilov Maksim <ulltor@gmail.com>
#
# @CODE
# Original Author: Gavrilov Maksim <ulltor@gmail.com>
# @CODE
# @BLURB: common ebuild functions for vala-based packages
# @DESCRIPTION:
# The vala eclass contains functions that make creating ebuild for
# vala-based applications much easier.
# Its main features are support of common portage default settings.

DEPEND=">=app-admin/eselect-vala-0.1"

case ${EAPI:-0} in
	4|3) EXPORT_FUNCTIONS get_active_version set_active_version \
			restore_original_version pkg_setup pkg_postinst ;;
	*) die "EAPI=${EAPI} is not supported" ;;
esac

########################
### HELPER FUNCTIONS ###
########################

# trim: deletes both leading and trailing whitespace
trim() {

		echo "${*}" | sed 's/^[ \t]*//;s/[ \t]*$//'

}

# clear_eselect_output: deletes annotations and whitespace from eselect output
clear_eselect_output() {

	echo $(trim $(echo "${*}" | sed '1d'))
	
}


# extract_version: extracts only version number from full filename
# Example: "$(extract_version /usr/bin/valac-0.12)" will be "0.12"
extract_version() {

	if [[ "$#" -ne 1 ]]; then
		die "${FUNCNAME}() accepts exactly one argument"
	fi
	
	if [[ "${1}" = "(unset)" ]]; then
		# no valac is set
		echo "0"
	else
	
		local result="${1##*-}"
		echo "${result:-0}"

	fi

}

###################
### GLOBAL VARS ###
###################

VALA_ORIGINAL_VERSION=""
VALA_REQUIRED_VERSION=""

##########################
### EXPORTED FUNCTIONS ###
##########################

# vala_get_active_version: returns active valac version, ex. "0.12"
vala_get_active_version() {

	if [[ "$#" -ne 0 ]]; then
		die "${FUNCNAME}() does not accept arguments"
	fi

	# get full path to current valac
	local output="$(eselect vala show)"
	local valacpath="$(clear_eselect_output "${output}")"
	echo "$(extract_version "${valacpath}")"

}

# vala_set_active_version: sets active valac due to the first argument
vala_set_active_version() {

	if [[ "$#" -ne 1 ]]; then
		die "${FUNCNAME}() accepts exactly one argument"
	fi

	if [[ -z "${VALA_ORIGINAL_VERSION}" ]]; then
		VALA_ORIGINAL_VERSION="$(vala_get_active_version)"
	fi

	ebegin "Setting active valac version to ${1}"
		eselect vala set ${1} 1>/dev/null 2>/dev/null
	eend $?

}

# vala_restore_original_version: restores the original valac that was active
# before package build started
vala_restore_original_version() {

	if [[ "${EBUILD_PHASE}" != "postinst" ]]; then
		die "${FUNCNAME}() can be used only in pkg_postinst() phase"
	fi

	if [[ "$#" -ne 0 ]]; then
		die "${FUNCNAME}() does not accept arguments"
	fi

	if [[ -n "${VALA_ORIGINAL_VERSION}" ]]; then
		vala_set_active_version "${VALA_ORIGINAL_VERSION}"
		return $?
	fi

}

# vala_pkg_setup: default pkg_setup for software written in Vala
vala_pkg_setup() {

	if [[ "${EBUILD_PHASE}" != "setup" ]]; then
		die "${FUNCNAME}() can be used only in pkg_setup() phase"
	fi

	if [[ "$#" -ne 0 ]]; then
		die "${FUNCNAME}() does not accept arguments"
	fi

	if [ -n "${VALA_REQUIRED_VERSION}" ]; then
		
		vala_set_active_version "${VALA_REQUIRED_VERSION}" || \
			die "changing valac active version to ${VALA_REQUIRED_VERSION} failed"
		eend $?
	fi

}

# vala_pkg_postinst: default pkg_postinst; sets back original valac version if 
# it has changed
vala_pkg_postinst() {

	if [[ "${EBUILD_PHASE}" != "postinst" ]]; then
		die "${FUNCNAME}() can be used only in pkg_postinst() phase"
	fi

	if [[ "$#" -ne 0 ]]; then
		die "${FUNCNAME}() does not accept arguments"
	fi
	
	vala_restore_original_version

}
