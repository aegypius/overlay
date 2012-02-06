# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils versionator bash-completion-r1

DESCRIPTION="Git extensions to provide high-level repository operations for Vincent Driessen's branching model."
HOMEPAGE="http://nvie.com/posts/a-successful-git-branching-model/"
SRC_URI="https://github.com/nvie/gitflow/tarball/${PV} -> ${P}.tar.gz
		 https://github.com/nvie/shFlags/tarball/1.0.3 -> shflags.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-vcs/git"
DEPEND="${RDEPEND}"


DOCS="AUTHORS LICENSE README Readme.md History.md"

src_unpack() {
	default
	mv nvie-gitflow-* ${P} || die
	rm -r ${P}/shFlags || die
	mv nvie-shFlags-* ${P}/shFlags || die
}

src_prepare() {
	:
}

src_compile() {
	:
}

src_install() {
	emake prefix="${D}/usr" install
	newbashcomp "${FILESDIR}/${PN}.bash-completion" ${PN}
}
