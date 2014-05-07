# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit versionator git-2 flag-o-matic

DESCRIPTION="Cross-platform desktop application shell"
HOMEPAGE="https://github.com/atom/atom-shell"
SRC_URI=""

EGIT_REPO_URI="git://github.com/atom/atom-shell"

LICENSE=""
SLOT="0"

if [[ ${PV} == *9999 ]];then
    KEYWORDS=""
else
    KEYWORDS="~amd64"
    EGIT_COMMIT="v${PV}"
fi

IUSE="debug"

DEPEND="
    sys-devel/clang:0/3.4
    dev-lang/python
"
RDEPEND="${DEPEND}"

RESTRICT="strip"

src_unpack() {
    git-2_src_unpack
}

src_prepare() {
    default_src_prepare

    # Bootstrap
    ./script/bootstrap.py

    # Fix libudev.so.0 link
    sed -i -e 's/libudev.so.0/libudev.so.1/g' \
        ./vendor/brightray/vendor/download/libchromiumcontent/Release/libchromiumcontent.so \
        || die "libudev fix failed"

}

src_compile() {
    OUT=out/$(usex debug Debug Release)
    ./script/build.py --configuration $(usex debug Debug Release)
    echo $PV > ${OUT}/version
    cp LICENSE $OUT
}

src_install() {

    prepall

    into    /usr/share/${PN}
    insinto /usr/share/${PN}
    exeinto /usr/share/${PN}

    cd ${OUT}

    doexe atom libchromiumcontent.so libffmpegsumo.so

    doins -r resources
    doins version
    doins content_shell.pak
    dosym /usr/share/${PN}/atom /usr/bin/${PN}

    dodoc LICENSE
}
