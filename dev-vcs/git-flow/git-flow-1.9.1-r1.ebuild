# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit bash-completion-r1

MY_PN="${PN/-/}"
COMP_PN="${PN}-completion"
COMP_PV="0.5.2"
COMP_P="${COMP_PN}-${COMP_PV}"

DESCRIPTION="AVH Edition of the git extensions for Vincent Driessen's branching model"
HOMEPAGE="https://github.com/petervanderdoes/gitflow-avh"
SRC_URI="
	https://github.com/petervanderdoes/${MY_PN}-avh/archive/${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/petervanderdoes/${COMP_PN}/archive/${COMP_PV}.tar.gz -> ${COMP_P}.tar.gz
"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror"

DEPEND=""
RDEPEND="${DEPEND}
	dev-vcs/git
"

DOCS=( AUTHORS Changes.mdown README.mdown )

S="${WORKDIR}/${MY_PN}-${PV}"

src_unpack() {
	default
	mv "gitflow-avh-${PV}" "${S}"
}

src_compile() {
	true
}

src_install() {
	emake prefix="${D}/usr" install
	einstalldocs
	newbashcomp "${WORKDIR}/${COMP_P}/${COMP_PN}.bash" ${PN}
}
