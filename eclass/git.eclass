# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/git.eclass,v 1.31 2009/10/20 10:05:47 scarabeus Exp $

# @ECLASS: git.eclass
# @MAINTAINER:
# Tomas Chvatal <scarabeus@gentoo.org>
# Donnie Berkholz <dberkholz@gentoo.org>
# @BLURB: This eclass provides functions for fetch and unpack git repositories
# @DESCRIPTION:
# The eclass is based on subversion eclass.
# If you use this eclass, the ${S} is ${WORKDIR}/${P}.
# It is necessary to define the EGIT_REPO_URI variable at least.
# @THANKS TO:
# Fernando J. Pereda <ferdy@gentoo.org>

inherit eutils

EGIT="git.eclass"

EXPORTED_FUNCTIONS="src_unpack"
case "${EAPI:-0}" in
   2) EXPORTED_FUNCTIONS="${EXPORTED_FUNCTIONS} src_prepare" ;;
   0|1) ;;
   *) die "Unknown EAPI, Bug eclass maintainers." ;;
esac
EXPORT_FUNCTIONS ${EXPORTED_FUNCTIONS}

# define some nice defaults but only if nothing is set already
: ${HOMEPAGE:=http://git-scm.com/}

# We DEPEND on at least a bit recent git version
DEPEND=">=dev-vcs/git-1.6"

# @ECLASS-VARIABLE: EGIT_QUIET
# @DESCRIPTION:
# Enables user specified verbosity for the eclass elog informations.
# The user just needs to add EGIT_QUIET="ON" to the /etc/make.conf.
: ${EGIT_QUIET:="OFF"}

# @ECLASS-VARIABLE: EGIT_STORE_DIR
# @DESCRIPTION:
# Storage directory for git sources.
# Can be redefined.
[[ -z ${EGIT_STORE_DIR} ]] && EGIT_STORE_DIR="${PORTAGE_ACTUAL_DISTDIR-${DISTDIR}}/git-src"

# @ECLASS-VARIABLE: EGIT_FETCH_CMD
# @DESCRIPTION:
# Command for cloning the repository.
: ${EGIT_FETCH_CMD:="git clone"}

# @ECLASS-VARIABLE: EGIT_UPDATE_CMD
# @DESCRIPTION:
# Git fetch command.
EGIT_UPDATE_CMD="git pull"

# @ECLASS-VARIABLE: EGIT_DIFFSTAT_CMD
# @DESCRIPTION:
# Git command for diffstat.
EGIT_DIFFSTAT_CMD="git --no-pager diff --stat"

# @ECLASS-VARIABLE: EGIT_OPTIONS
# @DESCRIPTION:
# This variable value is passed to clone and fetch.
: ${EGIT_OPTIONS:=}

# @ECLASS-VARIABLE: EGIT_REPO_URI
# @DESCRIPTION:
# URI for the repository
# e.g. http://foo, git://bar
# Supported protocols:
#   http://
#   https://
#   git://
#   git+ssh://
#   rsync://
#   ssh://
eval X="\$${PN//[-+]/_}_LIVE_REPO"
if [[ ${X} = "" ]]; then
   EGIT_REPO_URI=${EGIT_REPO_URI:=}
else
   EGIT_REPO_URI="${X}"
fi
# @ECLASS-VARIABLE: EGIT_PROJECT
# @DESCRIPTION:
# Project name of your ebuild.
# Git eclass will check out the git repository like:
#  ${EGIT_STORE_DIR}/${EGIT_PROJECT}/${EGIT_REPO_URI##*/}
# so if you define EGIT_REPO_URI as http://git.collab.net/repo/git or
# http://git.collab.net/repo/git. and PN is subversion-git.
# it will check out like:
#  ${EGIT_STORE_DIR}/subversion
: ${EGIT_PROJECT:=${PN/-git}}

# @ECLASS-VARIABLE: EGIT_BOOTSTRAP
# @DESCRIPTION:
# bootstrap script or command like autogen.sh or etc...
: ${EGIT_BOOTSTRAP:=}

# @ECLASS-VARIABLE: EGIT_OFFLINE
# @DESCRIPTION:
# Set this variable to a non-empty value to disable the automatic updating of
# an GIT source tree. This is intended to be set outside the git source
# tree by users.
EGIT_OFFLINE="${EGIT_OFFLINE:-${ESCM_OFFLINE}}"

# @ECLASS-VARIABLE: EGIT_PATCHES
# @DESCRIPTION:
# Similar to PATCHES array from base.eclass
# Only difference is that this patches are applied before bootstrap.
# Please take note that this variable should be bash array.

# @ECLASS-VARIABLE: EGIT_BRANCH
# @DESCRIPTION:
# git eclass can fetch any branch in git_fetch().
eval X="\$${PN//[-+]/_}_LIVE_BRANCH"
if [[ ${X} = "" ]]; then
   EGIT_BRANCH=${EGIT_BRANCH:=master}
else
   EGIT_BRANCH="${X}"
fi

# @ECLASS-VARIABLE: EGIT_COMMIT
# @DESCRIPTION:
# git eclass can checkout any commit.
eval X="\$${PN//[-+]/_}_LIVE_COMMIT"
if [[ ${X} = "" ]]; then
   : ${EGIT_COMMIT:=${EGIT_BRANCH}}
else
   EGIT_COMMIT="${X}"
fi

# @ECLASS-VARIABLE: EGIT_REPACK
# @DESCRIPTION:
# git eclass will repack objects to save disk space. However this can take a
# long time with VERY big repositories.
: ${EGIT_REPACK:=false}

# @ECLASS-VARIABLE: EGIT_PRUNE
# @DESCRIPTION:
# git eclass can prune the local clone. This is useful if upstream rewinds and
# rebases branches too often.
: ${EGIT_PRUNE:=false}

# @FUNCTION: git_submodules
# @DESCRIPTION:
# Internal function wrapping the submodule initialisation and update
git_sumbodules() {
   debug-print "git submodule init"
   git submodule init
   debug-print "git submodule update"
   git submodule update
}

# @FUNCTION: git_fetch
# @DESCRIPTION:
# Gets repository from EGIT_REPO_URI and store it in specified EGIT_STORE_DIR
git_fetch() {
   debug-print-function ${FUNCNAME} "$@"

   local GIT_DIR EGIT_CLONE_DIR oldsha1 cursha1

   # choose if user wants elog or just einfo.
   if [[ ${EGIT_QUIET} != OFF ]]; then
      elogcmd="einfo"
   else
      elogcmd="elog"
   fi

   # If we have same branch and the tree we can do --depth 1 clone
   # which outputs into really smaller data transfers.
   # Sadly we can do shallow copy for now because quite a few packages need .git
   # folder.
   #[[ ${EGIT_COMMIT} = ${EGIT_BRANCH} ]] && \
   #  EGIT_FETCH_CMD="${EGIT_FETCH_CMD} --depth 1"
   if [[ ! -z ${EGIT_TREE} ]] ; then
      EGIT_COMMIT=${EGIT_TREE}
      ewarn "QA: usage of deprecated EGIT_TREE variable detected."
      ewarn "QA: use EGIT_COMMIT variable instead."
   fi

   # EGIT_REPO_URI is empty.
   [[ -z ${EGIT_REPO_URI} ]] && die "${EGIT}: EGIT_REPO_URI is empty."

   # check for the protocol or pull from a local repo.
   if [[ -z ${EGIT_REPO_URI%%:*} ]] ; then
      case ${EGIT_REPO_URI%%:*} in
         git*|http|https|rsync|ssh) ;;
         *) die "${EGIT}: protocol for fetch from "${EGIT_REPO_URI%:*}" is not yet implemented in eclass." ;;
      esac
   fi

   # initial clone, we have to create master git storage directory and play
   # nicely with sandbox
   if [[ ! -d ${EGIT_STORE_DIR} ]] ; then
      debug-print "${FUNCNAME}: initial clone. creating git directory"
      addwrite /
      mkdir -p "${EGIT_STORE_DIR}" \
         || die "${EGIT}: can't mkdir ${EGIT_STORE_DIR}."
      export SANDBOX_WRITE="${SANDBOX_WRITE%%:/}"
   fi

   cd -P "${EGIT_STORE_DIR}" || die "${EGIT}: can't chdir to ${EGIT_STORE_DIR}"
   EGIT_STORE_DIR=${PWD}

   # allow writing into EGIT_STORE_DIR
   addwrite "${EGIT_STORE_DIR}"

   [[ -z ${EGIT_REPO_URI##*/} ]] && EGIT_REPO_URI="${EGIT_REPO_URI%/}"
   EGIT_CLONE_DIR="${EGIT_PROJECT}"

   debug-print "${FUNCNAME}: EGIT_OPTIONS = \"${EGIT_OPTIONS}\""

   GIT_DIR="${EGIT_STORE_DIR}/${EGIT_CLONE_DIR}"
   pushd ${EGIT_STORE_DIR} &> /dev/null
   # we also have to remove all shallow copied repositories
   # and fetch them again
   if [[ -e "${GIT_DIR}/shallow" ]]; then
      rm -rf "${GIT_DIR}"
      einfo "The ${EGIT_CLONE_DIR} was shallow copy. Refetching."
   fi
   # repack from bare copy to normal one
   if [[ -d ${GIT_DIR} && ! -d "${GIT_DIR}/.git/" ]]; then
      rm -rf "${GIT_DIR}"
      einfo "The ${EGIT_CLONE_DIR} was bare copy. Refetching."
   fi

   if [[ ! -d ${GIT_DIR} ]] ; then
      # first clone
      ${elogcmd} "GIT NEW clone -->"
      ${elogcmd} "   repository:       ${EGIT_REPO_URI}"

      debug-print "${EGIT_FETCH_CMD} ${EGIT_OPTIONS} \"${EGIT_REPO_URI}\" ${GIT_DIR}"
      ${EGIT_FETCH_CMD} ${EGIT_OPTIONS} "${EGIT_REPO_URI}" ${GIT_DIR} \
         || die "${EGIT}: can't fetch from ${EGIT_REPO_URI}."

      pushd "${GIT_DIR}" &> /dev/null
      cursha1=$(git rev-parse ${EGIT_BRANCH})
      ${elogcmd} "   at the commit:    ${cursha1}"

      git_sumbodules
      popd &> /dev/null
   elif [[ -n ${EGIT_OFFLINE} ]] ; then
      pushd "${GIT_DIR}" &> /dev/null
      cursha1=$(git rev-parse ${EGIT_BRANCH})
      ${elogcmd} "GIT offline update -->"
      ${elogcmd} "   repository:       ${EGIT_REPO_URI}"
      ${elogcmd} "   at the commit:    ${cursha1}"
      popd &> /dev/null
   else
      pushd "${GIT_DIR}" &> /dev/null
      # Git urls might change, so unconditionally set it here
      git config remote.origin.url "${EGIT_REPO_URI}"

      # fetch updates
      ${elogcmd} "GIT update -->"
      ${elogcmd} "   repository:       ${EGIT_REPO_URI}"

      oldsha1=$(git rev-parse ${EGIT_BRANCH})

      debug-print "${EGIT_UPDATE_CMD} ${EGIT_OPTIONS} origin ${EGIT_BRANCH}:${EGIT_BRANCH}"
      ${EGIT_UPDATE_CMD} ${EGIT_OPTIONS} origin ${EGIT_BRANCH}:${EGIT_BRANCH} \
         || die "${EGIT}: can't update from ${EGIT_REPO_URI}."

      git_sumbodules
      cursha1=$(git rev-parse ${EGIT_BRANCH})

      # write out message based on the revisions
      if [[ ${oldsha1} != ${cursha1} ]]; then
         ${elogcmd} "   updating from commit:   ${oldsha1}"
         ${elogcmd} "   to commit:     ${cursha1}"
      else
         ${elogcmd} "   at the commit:       ${cursha1}"
         # @ECLASS_VARIABLE: LIVE_FAIL_FETCH_IF_REPO_NOT_UPDATED
         # @DESCRIPTION:
         # If this variable is set to TRUE in make.conf or somewhere in
         # enviroment the package will fail if there is no update, thus in
         # combination with --keep-going it would lead in not-updating
         # pakcages that are up-to-date.
         # TODO: this can lead to issues if more projects/packages use same repo
         [[ ${LIVE_FAIL_FETCH_IF_REPO_NOT_UPDATED} = true ]] && \
            debug-print "${FUNCNAME}: Repository \"${EGIT_REPO_URI}\" is up-to-date. Skipping." && \
            die "${EGIT}: Repository \"${EGIT_REPO_URI}\" is up-to-date. Skipping."
      fi
      ${EGIT_DIFFSTAT_CMD} ${oldsha1}..${EGIT_BRANCH}
      popd &> /dev/null
   fi

   pushd "${GIT_DIR}" &> /dev/null
   if ${EGIT_REPACK} || ${EGIT_PRUNE} ; then
      ebegin "Garbage collecting the repository"
      git gc $(${EGIT_PRUNE} && echo '--prune')
      eend $?
   fi
   popd &> /dev/null

   # export the git version
   export EGIT_VERSION="${cursha1}"

   [[ ${EGIT_COMMIT} != ${EGIT_BRANCH} ]] && elog "   tree:       ${EGIT_COMMIT}"
   ${elogcmd} "   branch:        ${EGIT_BRANCH}"
   ${elogcmd} "   storage directory:   \"${EGIT_STORE_DIR}/${EGIT_CLONE_DIR}\""

   # unpack to the ${S}
   popd &> /dev/null
   debug-print "cp -aR \"${GIT_DIR}\" \"${S}\""
   cp -aR "${GIT_DIR}" "${S}"

   # set correct branch and the tree ebuild specified
   pushd "${S}" > /dev/null
   local branchname=branch-${EGIT_BRANCH} src=origin/${EGIT_BRANCH}
   if [[ ${EGIT_COMMIT} != ${EGIT_BRANCH} ]]; then
      branchname=tree-${EGIT_COMMIT}
      src=${EGIT_COMMIT}
   fi
   debug-print "git checkout -b ${branchname} ${src}"
   git checkout -b ${branchname} ${src} 2>&1 > /dev/null
   git_sumbodules
   popd > /dev/null

   unset branchname src

   echo ">>> Unpacked to ${S}"
}

# @FUNCTION: git_bootstrap
# @DESCRIPTION:
# Runs bootstrap command if EGIT_BOOTSTRAP variable contains some value
# Remember that what ever gets to the EGIT_BOOTSTRAP variable gets evaled by bash.
git_bootstrap() {
   debug-print-function ${FUNCNAME} "$@"

   if [[ -n ${EGIT_BOOTSTRAP} ]] ; then
      pushd "${S}" > /dev/null
      einfo "Starting bootstrap"

      if [[ -f ${EGIT_BOOTSTRAP} ]]; then
         # we have file in the repo which we should execute
         debug-print "$FUNCNAME: bootstraping with file \"${EGIT_BOOTSTRAP}\""

         if [[ -x ${EGIT_BOOTSTRAP} ]]; then
            eval "./${EGIT_BOOTSTRAP}" \
               || die "${EGIT}: bootstrap script failed"
         else
            eerror "\"${EGIT_BOOTSTRAP}\" is not executable."
            eerror "Report upstream, or bug ebuild maintainer to remove bootstrap command."
            die "${EGIT}: \"${EGIT_BOOTSTRAP}\" is not executable."
         fi
      else
         # we execute some system command
         debug-print "$FUNCNAME: bootstraping with commands \"${EGIT_BOOTSTRAP}\""

         eval "${EGIT_BOOTSTRAP}" \
            || die "${EGIT}: bootstrap commands failed."

      fi

      einfo "Bootstrap finished"
      popd > /dev/null
   fi
}

# @FUNCTION: git_apply_patches
# @DESCRIPTION:
# Apply patches from EGIT_PATCHES bash array.
# Preffered is using the variable as bash array but for now it allows to write
# it also as normal space separated string list. (This part of code should be
# removed when all ebuilds get converted on bash array).
git_apply_patches() {
   debug-print-function ${FUNCNAME} "$@"

   pushd "${S}" > /dev/null
   if [[ ${#EGIT_PATCHES[@]} -gt 1 ]] ; then
      for i in "${EGIT_PATCHES[@]}"; do
         debug-print "$FUNCNAME: git_autopatch: patching from ${i}"
         epatch "${i}"
      done
   elif [[ ${EGIT_PATCHES} != "" ]]; then
      # no need for loop if space separated string is passed.
      debug-print "$FUNCNAME: git_autopatch: patching from ${EGIT_PATCHES}"
      epatch "${EGIT_PATCHES}"
   fi

   popd > /dev/null
}

# @FUNCTION: git_src_unpack
# @DESCRIPTION:
# src_upack function, calls src_prepare one if EAPI!=2.
git_src_unpack() {
   debug-print-function ${FUNCNAME} "$@"

   git_fetch || die "${EGIT}: unknown problem in git_fetch()."

   has src_prepare ${EXPORTED_FUNCTIONS} || git_src_prepare
}

# @FUNCTION: git_src_prepare
# @DESCRIPTION:
# src_prepare function for git stuff. Patches, bootstrap...
git_src_prepare() {
   debug-print-function ${FUNCNAME} "$@"

   git_apply_patches
   git_bootstrap
}