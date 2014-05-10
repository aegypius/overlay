# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit versionator git-2 flag-o-matic

DESCRIPTION="A hackable text editor for the 21st Century"
HOMEPAGE="https://atom.io"
SRC_URI=""

EGIT_REPO_URI="git://github.com/atom/atom"

LICENSE="MIT"
SLOT="0"

if [[ ${PV} == *9999 ]];then
    KEYWORDS=""
else
    KEYWORDS="~amd64"
    EGIT_COMMIT="v${PV}"
fi

IUSE=""

DEPEND="
    dev-util/atom-shell
    >=net-libs/nodejs-0.10[npm]
"
RDEPEND="${DEPEND}"
RESTRICT="strip"

src_unpack() {
    git-2_src_unpack
}

src_prepare() {
    default_src_prepare

    epatch ${FILESDIR}/0001-fix-atom-shell-path.patch
}

src_compile() {
    ./script/build --verbose --build-dir ${T} || die "Failed to compile"
}

src_install() {
    prepall

    into    /usr
    insinto /usr/share/${PN}
    exeinto /usr/bin

    cd ${T}/Atom
    dodoc LICENSE version

    cd ${T}/Atom/resources/app

    # Installs everything in Atom/resources/app
    doins -r .

    # Fixes permissions
    fperms +x /usr/share/${PN}/atom.sh
    fperms +x /usr/share/${PN}/apm/node_modules/.bin/apm
    fperms +x /usr/share/${PN}/apm/node_modules/atom-package-manager/bin/node

    # Symlinking to /usr/bin
    dosym ../share/${PN}/atom.sh /usr/bin/atom
    dosym ../share/${PN}/apm/node_modules/atom-package-manager/bin/apm /usr/bin/apm


}
