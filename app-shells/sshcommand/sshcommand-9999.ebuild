# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Turn SSH into a thin client specifically for your app"
HOMEPAGE="https://github.com/progrium/sshcommand"
SRC_URI=""

EGIT_REPO_URI="git://github.com/progrium/sshcommand"
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

DEPEND=""
RDEPEND="${DEPEND}
    app-shells/bash
"

src_unpack() {
    git-2_src_unpack
}

src_install() {
    exeinto /usr/bin
    doexe sshcommand
}
