# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit versionator

BRACKETS_SPRINT=$(get_version_component_range 2-2)

DESCRIPTION="An open source code editor for the web, written in Javascript, HTML and CSS."
HOMEPAGE="http://brackets.io"
SRC_URI="https://github.com/adobe/brackets-shell/archive/sprint-${BRACKETS_SPRINT}.tar.gz -> brackets-shell-sprint-${BRACKETS_SPRINT}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror"
IUSE=""

DEPEND="
    net-libs/nodejs
    dev-vcs/git
"
RDEPEND="${DEPEND}"

src_unpack() {
    default_src_unpack

    mkdir ${S}
    mv ${WORKDIR}/brackets-shell-sprint-${BRACKETS_SPRINT} ${S}/brackets-shell

    einfo "Fetching brackets"
    cd ${S}
    git clone --depth 1 --recursive --branch sprint-${BRACKETS_SPRINT} \
        https://github.com/adobe/brackets.git \
        || die "Failed to checkout sprint-${BRACKETS_SPRINT}"

    S=${S}/brackets-shell
}

src_prepare() {
    default_src_prepare
    PATH=$(npm bin):$PATH
    npm install grunt-cli || die "Failed to install grunt-cli"
    npm install           || die "Failed to install nodejs dependencies"
    grunt setup --verbose || die "Failed to setup grunt"

    # link against libudev.so.1 instead of libudev.so.0
    sed -i \
        -e 's/libudev.so.0/libudev.so.1/g' \
        deps/cef/Release/libcef.so || die "sed failed"

    # Fix QA notice for desktop file
    sed -i \
        -re "s/(Categories=.*)([;]+)?/\1;/g" \
        installer/linux/debian/brackets.desktop || die "sed failed"
}

src_compile() {
    grunt full-build --verbose || die "Failed to compile"
}

src_install() {
    cd ${S}/installer/linux/debian/package-root/opt/brackets

    prepall

    into    /opt/${PN}
    insinto /opt/${PN}
    exeinto /opt/${PN}

    doins appshell32.png
    doins appshell48.png
    doins appshell128.png
    doins appshell256.png
    doins cef.pak
    doins devtools_resources.pak

    doexe brackets Brackets Brackets-node

    doins -r lib
    doins -r locales
    doins -r node-core
    doins -r samples
    doins -r www

    dosym /opt/${PN}/brackets /usr/bin/brackets

    insinto /usr/share/applications
    doins brackets.desktop

    cd ${S}/installer/linux/debian/package-root/usr/share
    dodoc doc/brackets/copyright
    doicon -s scalable icons/hicolor/scalable/apps/brackets.svg
}
