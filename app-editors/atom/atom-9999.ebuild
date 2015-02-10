# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )
inherit git-r3 flag-o-matic python-any-r1 eutils

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
	${PYTHON_DEPS}
	dev-util/atom-shell:0/21
	=net-libs/nodejs-0.10*[npm]
	media-fonts/inconsolata
"
RDEPEND="${DEPEND}"

QA_PRESTRIPPED="
	/usr/share/atom/resources/app/node_modules/symbols-view/vendor/ctags-linux
"
pkg_setup() {
	python-any-r1_pkg_setup

	npm config set python $PYTHON
}

src_unpack() {
	git-r3_src_unpack
}

src_prepare() {
	# Skip atom-shell download
	sed -i -e "s/defaultTasks = \['download-atom-shell', /defaultTasks = [/g" \
		./build/Gruntfile.coffee \
		|| die "Failed to fix Gruntfile"

	# Skip atom-shell copy
	epatch "${FILESDIR}/0002-skip-atom-shell-copy.patch"

	# Fix atom location guessing
	sed -i -e 's/ATOM_PATH="$USR_DIRECTORY\/share\/atom/ATOM_PATH="$USR_DIRECTORY\/../g' \
		./atom.sh \
		|| die "Fail fixing atom-shell directory"

	# Make bootstrap process more verbose
	sed -i -e 's@node script/bootstrap@node script/bootstrap --no-quiet@g' \
		./script/build \
		|| die "Fail fixing verbosity of script/build"
}

src_compile() {
	./script/build --verbose --build-dir "${T}" || die "Failed to compile"

	"${T}/Atom/resources/app/apm/bin/apm" rebuild || die "Failed to rebuild native module"

	# Setup python path to builtin npm
	echo "python = $PYTHON" >> "${T}/Atom/resources/app/apm/.apmrc"
}

src_install() {

	into	/usr

	insinto /usr/share/applications

	insinto /usr/share/${PN}/resources/app
	exeinto /usr/bin

	cd "${T}/Atom/resources/app"
	doicon resources/atom.png
	dodoc LICENSE.md

	# Installs everything in Atom/resources/app
	doins -r .

	# Fixes permissions
	fperms +x /usr/share/${PN}/resources/app/atom.sh
	fperms +x /usr/share/${PN}/resources/app/apm/bin/apm
	fperms +x /usr/share/${PN}/resources/app/apm/bin/node
	fperms +x /usr/share/${PN}/resources/app/apm/node_modules/npm/bin/node-gyp-bin/node-gyp

	# Symlinking to /usr/bin
	dosym ../share/${PN}/resources/app/atom.sh /usr/bin/atom
	dosym ../share/${PN}/resources/app/apm/bin/apm /usr/bin/apm

	make_desktop_entry "/usr/bin/atom %U" "Atom" "atom" "GNOME;GTK;Utility;TextEditor;Development;" "MimeType=text/plain;\nStartupNotify=true\nStartupWMClass=Atom"
}
