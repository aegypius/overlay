# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 )
inherit git-r3 flag-o-matic python-any-r1

DESCRIPTION="Build Cross-platform desktop application shell with web technologies"
HOMEPAGE="https://electron.atom.io"
SRC_URI=""

EGIT_REPO_URI="git://github.com/atom/electron"

LICENSE="MIT"
SLOT="0/22"

if [[ ${PV} == *9999 ]];then
	KEYWORDS=""
else
	KEYWORDS="~amd64"
	EGIT_COMMIT="v${PV}"
fi

IUSE="debug"

DEPEND="
	${PYTHON_DEPS}
	>=sys-devel/llvm-3.5.0[clang]
	dev-lang/python:2.7
	|| ( >=net-libs/nodejs-0.12.0[npm] net-libs/iojs[npm] )
	x11-libs/gtk+:2
	x11-libs/libnotify
	gnome-base/libgnome-keyring
	gnome-base/gconf
	dev-libs/nss
	dev-libs/nspr
	media-libs/alsa-lib
	net-print/cups
	sys-libs/libcap
	x11-libs/libXtst
	x11-libs/pango
	dev-util/ninja
	sys-libs/ncurses:*[tinfo]
"
RDEPEND="${DEPEND}"

QA_PRESTRIPPED=""

src_unpack() {
	git-r3_src_unpack
}

pkg_setup() {
	python-any-r1_pkg_setup

	# Update npm config to use python 2
	# npm config set python $PYTHON
}

src_prepare() {
	einfo "npm version: "
	einfo $(npm version)

	$PYTHON script/bootstrap.py --verbose || die "Failed to bootstrap electron"
}

src_compile() {
	# epatch "${FILESDIR}/${PN}-fix-static-locations.patch" || die "Failed to patch"

	$PYTHON script/build.py --configuration $(usex debug Debug Release) || die "Failed to bootstrap electron"
}

src_install() {
	die "installing"
}
