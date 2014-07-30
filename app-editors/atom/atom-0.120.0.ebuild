# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-2 flag-o-matic python

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
    =dev-util/atom-shell-0.15.0
    >=net-libs/nodejs-0.10.29[npm]
"
RDEPEND="${DEPEND}"

QA_PRESTRIPPED="
   /usr/share/atom/node_modules/symbols-view/vendor/ctags-linux
"

PYTHON_DEPEND="2"
RESTRICT_PYTHON_ABIS="3.*"

pkg_setup() {
    python_set_active_version 2
    python_pkg_setup

    # Update npm config to use python 2
    export PYTHON=$(PYTHON -a)
    npm config set python $(PYTHON -a)
}

src_unpack() {
    git-2_src_unpack
}

src_prepare() {
    default_src_prepare

    # Fix atom-shell invocation
    sed -i -e 's@$USR_DIRECTORY/share/atom@$USR_DIRECTORY/atom-shell@g' \
      ./atom.sh \
      || die "Fail fixing atom-shell directory"

    sed -i -e 's/"$ATOM_PATH" --executed-from/"$ATOM_PATH" $ATOM_RESOURCE_PATH --executed-from/g' \
      ./atom.sh \
      || die "Fail fixing atom-shell invocation"

}

src_compile() {
    ./script/build --verbose --build-dir ${T} || die "Failed to compile"
}

src_install() {
    prepall

    into    /usr

    newenvd "${FILESDIR}"/atom.envd 99atom

    insinto /usr/share/applications
    newins  "${FILESDIR}"/atom.desktop atom.desktop

    insinto /usr/share/${PN}
    exeinto /usr/bin

    cd ${T}/Atom
    dodoc LICENSE

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
