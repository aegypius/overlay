# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Simple dispatcher and protocol for shell-based plugins, an improvement to hook scripts"
HOMEPAGE="https://github.com/progrium/pluginhook"
SRC_URI=""

EGIT_REPO_URI="git://github.com/progrium/pluginhook"
if [[ ${PV} == *9999 ]]; then
    KEYWORDS=""
else
    KEYWORDS="~amd64"
    EGIT_COMMIT="v${PV}"
fi

inherit git-2

LICENSE="MIT"
SLOT="0"
IUSE=""

DEPEND="
    >=dev-lang/go-1.1.2
"
RDEPEND="${DEPEND}"

src_unpack() {
    git-2_src_unpack
}

src_prepare() {
    export GOPATH="${WORKDIR}/gopath"
    mkdir $GOPATH || die

    # make sure pluginhook itself is in our shiny new GOPATH
    mkdir -p "${GOPATH}/src/github.com/progrium" || die
    ln -sf "$(pwd -P)" "${GOPATH}/src/github.com/progrium/${PN}" || die

    go get code.google.com/p/go.crypto/ssh/terminal
}

src_install() {
    exeinto /usr/bin
    newexe pluginhook.linux pluginhook
}
