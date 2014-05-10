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


src_unpack() {
    git-2_src_unpack
}

src_prepare() {
    default_src_prepare

    epatch ${FILESDIR}/0001-fix-atom-shell-path.patch
}

src_compile() {
    OUT=${S}/out
    ./script/build --build-dir ${OUT}
}

src_install() {

    prepall

    into    /usr/share/${PN}
    insinto /usr/share/${PN}
    exeinto /usr/share/${PN}

    cd $OUT/Atom
    dodoc LICENSE

    cd ${OUT}/Atom/resources/app
    doins -r .

    dosym /usr/share/${PN}/atom.sh /usr/bin/${PN}
    dosym /usr/share/${PN}/apm/node_modules/atom-package-manager/bin/apm /usr/bin/apm

}
