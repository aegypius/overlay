# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-2 flag-o-matic python

DESCRIPTION="Cross-platform desktop application shell"
HOMEPAGE="https://github.com/atom/atom-shell"
SRC_URI=""

EGIT_REPO_URI="git://github.com/atom/atom-shell"

LICENSE="MIT"
SLOT="0"

if [[ ${PV} == *9999 ]];then
    KEYWORDS=""
else
    KEYWORDS="~amd64"
    EGIT_COMMIT="v${PV}"
fi

IUSE="debug"

DEPEND="
    sys-devel/llvm:0/3.4[clang]
    dev-lang/python:2.7
    >=net-libs/nodejs-0.10.29[npm]
    x11-libs/gtk+:2
    x11-libs/libnotify
    gnome-base/libgnome-keyring
    dev-libs/nss
    dev-libs/nspr
    gnome-base/gconf
    media-libs/alsa-lib
    net-print/cups
"
RDEPEND="${DEPEND}"

QA_PRESTRIPPED="
    /usr/share/atom-shell/libffmpegsumo.so
    /usr/share/atom-shell/libchromiumcontent.so
"

PYTHON_DEPEND="2"
RESTRICT_PYTHON_ABIS="3.*"

src_unpack() {
    git-2_src_unpack
}

pkg_setup() {
    python_set_active_version 2
    python_pkg_setup

    # Update npm config to use python 2
    export PYTHON=$(PYTHON -a)
    npm config set python $(PYTHON -a)
}

src_prepare() {
    default_src_prepare

    # Bootstrap
    ./script/bootstrap.py || die "bootstrap failed"

    # Fix libudev.so.0 link
    sed -i -e 's/libudev.so.0/libudev.so.1/g' \
        ./vendor/brightray/vendor/download/libchromiumcontent/Release/libchromiumcontent.so \
        || die "libudev fix failed"

}

src_compile() {
    OUT=out/$(usex debug Debug Release)
    ./script/build.py --configuration $(usex debug Debug Release) || die "Compilation failed"
    echo "v$PV" > ${OUT}/version
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
