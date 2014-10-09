# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit bash-completion-r1

DESCRIPTION="AVH Edition of the git extensions to provide high-level repository operations for Vincent Driessen's branching model"
HOMEPAGE="https://github.com/petervanderdoes/gitflow"
SRC_URI="https://github.com/petervanderdoes/gitflow/archive/${PV}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
# IUSE="bash-completion"
RESTRICT="mirror"

DEPEND="
	app-shells/bash
"
RDEPEND="${DEPEND}
	dev-vcs/git
"
src_compile() {
	true
}

src_install() {
	exeinto /usr/bin
	doexe git-flow

	insinto /usr/bin
	doins git-flow-config
	doins git-flow-feature
	doins git-flow-hotfix
	doins git-flow-init
	doins git-flow-release
	doins git-flow-support
	doins git-flow-version
	doins gitflow-common
	doins gitflow-shFlags

	insinto /usr/share/${PN}
	doins -r hooks

	newbashcomp "${FILESDIR}/${PN}-${PV}.bash-completion" ${PN}

}
