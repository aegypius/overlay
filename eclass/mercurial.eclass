# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mercurial.eclass,v 1.13 2010/08/24 16:49:18 robbat2 Exp $

# @ECLASS: mercurial.eclass
# @MAINTAINER:
# Krzysztof Pawlik <nelchael@gentoo.org>
# Dirkjan Ochtman <djc@gentoo.org>
# @BLURB: This eclass provides generic mercurial fetching functions
# @DESCRIPTION:
# This eclass provides generic mercurial fetching functions. To fetch sources
# from mercurial repository just set EHG_REPO_URI to correct repository URI. If
# you need to share single repository between several ebuilds set EHG_PROJECT to
# project name in all of them.

inherit eutils

EXPORT_FUNCTIONS src_unpack

DEPEND="dev-vcs/mercurial"

# @ECLASS-VARIABLE: EHG_REPO_URI
# @DESCRIPTION:
# Mercurial repository URI.

# @ECLASS-VARIABLE: EHG_REVISION
# @DESCRIPTION:
# Create working directory for specified revision, defaults to tip.
#
# EHG_REVISION is passed as a value for --rev parameter, so it can be more than
# just a revision, please consult `hg help revisions' for more details.
[[ -z "${EHG_REVISION}" ]] && EHG_REVISION="tip"

# @ECLASS-VARIABLE: EHG_STORE_DIR
# @DESCRIPTION:
# Mercurial sources store directory. Users may override this in /etc/make.conf
[[ -z "${EHG_STORE_DIR}" ]] && EHG_STORE_DIR="${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/hg-src"

# @ECLASS-VARIABLE: EHG_PROJECT
# @DESCRIPTION:
# Project name.
#
# This variable default to $PN, but can be changed to allow repository sharing
# between several ebuilds.
[[ -z "${EHG_PROJECT}" ]] && EHG_PROJECT="${PN}"

# @ECLASS-VARIABLE: EHG_QUIET
# @DESCRIPTION:
# Suppress some extra noise from mercurial, set it to 'OFF' to be louder.
: ${EHG_QUIET:="ON"}
[[ "${EHG_QUIET}" == "ON" ]] && EHG_QUIET_CMD_OPT="--quiet"

# @ECLASS-VARIABLE: EHG_CLONE_CMD
# @DESCRIPTION:
# Command used to perform initial repository clone.
[[ -z "${EHG_CLONE_CMD}" ]] && EHG_CLONE_CMD="hg clone ${EHG_QUIET_CMD_OPT} --pull --noupdate"

# @ECLASS-VARIABLE: EHG_PULL_CMD
# @DESCRIPTION:
# Command used to update repository.
[[ -z "${EHG_PULL_CMD}" ]] && EHG_PULL_CMD="hg pull ${EHG_QUIET_CMD_OPT}"

# @ECLASS-VARIABLE: EHG_OFFLINE
# @DESCRIPTION:
# Set this variable to a non-empty value to disable the automatic updating of
# a mercurial source tree. This is intended to be set outside the ebuild by
# users.
EHG_OFFLINE="${EHG_OFFLINE:-${ESCM_OFFLINE}}"

# @FUNCTION: mercurial_fetch
# @USAGE: [repository_uri] [module]
# @DESCRIPTION:
# Clone or update repository.
#
# If not repository URI is passed it defaults to EHG_REPO_URI, if module is
# empty it defaults to basename of EHG_REPO_URI.
function mercurial_fetch {
	debug-print-function ${FUNCNAME} ${*}

	EHG_REPO_URI=${1-${EHG_REPO_URI}}
	[[ -z "${EHG_REPO_URI}" ]] && die "EHG_REPO_URI is empty"

	local module="${2-$(basename "${EHG_REPO_URI}")}"

	# Should be set but blank to prevent using $HOME/.hgrc
	export HGRCPATH=

	# Check ${EHG_STORE_DIR} directory:
	addwrite "$(dirname "${EHG_STORE_DIR}")" || die "addwrite failed"
	if [[ ! -d "${EHG_STORE_DIR}" ]]; then
		mkdir -p "${EHG_STORE_DIR}" || die "failed to create ${EHG_STORE_DIR}"
		chmod -f g+rw "${EHG_STORE_DIR}" || \
			die "failed to chown ${EHG_STORE_DIR}"
	fi

	# Create project directory:
	mkdir -p "${EHG_STORE_DIR}/${EHG_PROJECT}" || \
		die "failed to create ${EHG_STORE_DIR}/${EHG_PROJECT}"
	chmod -f g+rw "${EHG_STORE_DIR}/${EHG_PROJECT}" || \
		echo "Warning: failed to chmod g+rw ${EHG_PROJECT}"
	cd "${EHG_STORE_DIR}/${EHG_PROJECT}" || \
		die "failed to cd to ${EHG_STORE_DIR}/${EHG_PROJECT}"

	# Clone/update repository:
	if [[ ! -d "${module}" ]]; then
		einfo "Cloning ${EHG_REPO_URI} to ${EHG_STORE_DIR}/${EHG_PROJECT}/${module}"
		${EHG_CLONE_CMD} "${EHG_REPO_URI}" "${module}" || {
			rm -rf "${module}"
			die "failed to clone ${EHG_REPO_URI}"
		}
		cd "${module}"
	elif [[ -z "${EHG_OFFLINE}" ]]; then
		einfo "Updating ${EHG_STORE_DIR}/${EHG_PROJECT}/${module} from ${EHG_REPO_URI}"
		cd "${module}" || die "failed to cd to ${module}"
		${EHG_PULL_CMD} || die "update failed"
	fi

	# Checkout working copy:
	einfo "Creating working directory in ${WORKDIR}/${module} (target revision: ${EHG_REVISION})"
	hg clone \
		${EHG_QUIET_CMD_OPT} \
		--rev="${EHG_REVISION}" \
		"${EHG_STORE_DIR}/${EHG_PROJECT}/${module}" \
		"${WORKDIR}/${module}" || die "hg clone failed"
	# An exact revision helps a lot for testing purposes, so have some output...
	# id           num  branch
	# fd6e32d61721 6276 default
	local HG_REVDATA=($(hg identify -b -i "${WORKDIR}/${module}"))
	local HG_REV_ID=${HG_REVDATA[0]}
	local HG_REV_BRANCH=${HG_REVDATA[1]}
	einfo "Work directory: ${WORKDIR}/${module} global id: ${HG_REV_ID} branch: ${HG_REV_BRANCH}"
}

# @FUNCTION: mercurial_src_unpack
# @DESCRIPTION:
# The mercurial src_unpack function, which will be exported.
function mercurial_src_unpack {
	mercurial_fetch
}
