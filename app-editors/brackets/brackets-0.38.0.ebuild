# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit versionator git-2

BRACKETS_SPRINT=$(get_version_component_range 2-2)

DESCRIPTION="CEF3-based application shell for Brackets"
HOMEPAGE="http://brackets.io"
SRC_URI=""

EGIT_REPO_URI="git://github.com/adobe/brackets-shell"

if [[ ${PV} == *9999 ]];then
	KEYWORDS=""
else
	KEYWORDS="~amd64"
	EGIT_COMMIT="sprint-${BRACKETS_SPRINT}"
fi

LICENSE=""
SLOT="0"
IUSE=""

DEPEND="
	net-libs/nodejs
"
RDEPEND="${DEPEND}"

src_unpack() {
    git-2_src_unpack

    mv ${S} ${WORKDIR}/${PN}-shell
    mkdir ${S}
    mv ${WORKDIR}/${PN}-shell ${S}
    BRACKETS_SHELL_S=${S}/brackets-shell

    einfo "Fetching brackets"
    cd ${S}
    git clone --depth 1 --recursive --branch ${EGIT_COMMIT} \
        https://github.com/adobe/brackets.git \
        || die "Failed to checkout brackets ${PV}"

    BRACKETS_S=${S}/brackets
}


src_prepare() {
	default_src_prepare


    einfo "Preparing brackets"
    cd ${BRACKETS_S}
    npm install grunt-cli            || die "Failed to install grunt-cli"
    npm install                      || die "Failed to install nodejs dependencies"

    einfo "Preparing brackets-shell"
    cd ${BRACKETS_SHELL_S}
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
	PATH=$(npm bin):$PATH

    einfo "Building brackets"
    cd ${BRACKETS_S}
    grunt build --verbose || die "Failed to compile"

    einfo "Building brackets-shell"
    cd ${BRACKETS_SHELL_S}
    grunt full-build --verbose || die "Failed to compile"
}

src_install() {
    DEBIAN_ROOT_DIR=${BRACKETS_SHELL_S}/installer/linux/debian/package-root

    prepall

    into    /opt/${PN}
    insinto /opt/${PN}
    exeinto /opt/${PN}

    cd ${DEBIAN_ROOT_DIR}/opt/brackets
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

    cd ${DEBIAN_ROOT_DIR}/usr/share
    dodoc doc/brackets/copyright
    doicon -s scalable icons/hicolor/scalable/apps/brackets.svg
}
