# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit versionator

DESCRIPTION="GIT utilities -- repo summary, repl, changelog population, author commit percentages and more..."
HOMEPAGE="https://github.com/visionmedia/git-extras"
SRC_URI="https://github.com/visionmedia/git-extras/tarball/${PV} -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-vcs/git"
DEPEND="${RDEPEND}"


DOCS="AUTHORS LICENSE README Readme.md History.md"

src_unpack() {
	default
	mv * ${P} || die
}

src_compile() {
	:
}

src_install() {
	emake PREFIX="${D}/usr" install
}
