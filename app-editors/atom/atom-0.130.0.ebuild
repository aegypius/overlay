# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-2 flag-o-matic python eutils

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
    >=dev-util/atom-shell-0.15.9
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
    default

    # Skip atom-shell download
    sed -i -e "s/defaultTasks = \['download-atom-shell', /defaultTasks = [/g" \
      ./build/Gruntfile.coffee \
      || die "Failed to fix Gruntfile"

    # Skip atom-shell copy
    epatch ${FILESDIR}/0002-skip-atom-shell-copy.patch

    # Fix atom location guessing
    sed -i -e 's/ATOM_PATH="$USR_DIRECTORY\/share\/atom/ATOM_PATH="$USR_DIRECTORY\/../g' \
      ./atom.sh \
      || die "Fail fixing atom-shell directory"
}

src_compile() {
    ./script/build --verbose --build-dir ${T} || die "Failed to compile"

    ${T}/Atom/resources/app/apm/node_modules/atom-package-manager/bin/apm rebuild || die "Failed to rebuild native module"
}

src_install() {
    prepall

    into    /usr

    insinto /usr/share/applications

    insinto /usr/share/${PN}/resources/app
    exeinto /usr/bin

    cd ${T}/Atom/resources/app
    doicon resources/atom.png
    dodoc LICENSE.md

    # Installs everything in Atom/resources/app
    doins -r .

    # Fixes permissions
    fperms +x /usr/share/${PN}/resources/app/atom.sh
    fperms +x /usr/share/${PN}/resources/app/apm/node_modules/.bin/apm
    fperms +x /usr/share/${PN}/resources/app/apm/node_modules/atom-package-manager/bin/node

    # Symlinking to /usr/bin
    dosym ../share/${PN}/resources/app/atom.sh /usr/bin/atom
    dosym ../share/${PN}/resources/app/apm/node_modules/atom-package-manager/bin/apm /usr/bin/apm

    make_desktop_entry "/usr/bin/atom %U" "Atom" "atom" "GNOME;GTK;Utility;TextEditor;Development;" "MimeType=text/plain;\nStartupNotify=true\nStartupWMClass=Atom Shell"
}
