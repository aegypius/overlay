# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )
inherit git-r3 flag-o-matic python-any-r1

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
	${PYTHON_DEPS}
	sys-devel/llvm:0/3.4[clang]
	dev-lang/python:2.7
	>=net-libs/nodejs-0.10.30[npm]
	x11-libs/gtk+:2
	x11-libs/libnotify
	gnome-base/libgnome-keyring
	dev-libs/nss
	dev-libs/nspr
	gnome-base/gconf
	media-libs/alsa-lib
	net-print/cups
	sys-libs/libcap
	x11-libs/libXtst
	x11-libs/pango
"
RDEPEND="${DEPEND}
	!<app-editors/atom-0.120.0
"

QA_PRESTRIPPED="
	/usr/share/atom/libffmpegsumo.so
	/usr/share/atom/libchromiumcontent.so
"
src_unpack() {
	git-r3_src_unpack
}

pkg_setup() {
	python-any-r1_pkg_setup

	# Update npm config to use python 2
	npm config set python $PYTHON
}

src_prepare() {
	einfo "Bootstrap atom-shell source"

	# Fix util.execute function to be more verbose
	sed -i -e 's/def execute(argv):/def execute(argv):\n  print "   - bootstrap: " + " ".join(argv)/g' \
	  ./script/lib/util.py \
	  || die "Failed to sed lib/util.py"

	# Bootstrap
	./script/bootstrap.py || die "bootstrap failed"

	# Fix libudev.so.0 link
	sed -i -e 's/libudev.so.0/libudev.so.1/g' \
		./vendor/brightray/vendor/download/libchromiumcontent/Release/libchromiumcontent.so \
		|| die "libudev fix failed"

	# Make every subprocess calls fatal
	sed -i -e 's/subprocess.call(/subprocess.check_call(/g' \
		./script/build.py \
		|| die "build fix failed"

	# Update ninja files
	./script/update.py || die "update failed"
}

src_compile() {
	OUT=out/$(usex debug Debug Release)
	./script/build.py --configuration $(usex debug Debug Release) || die "Compilation failed"
	echo "v$PV" > "${OUT}/version"
	cp LICENSE "$OUT"
}

src_install() {

	into	/usr/share/atom
	insinto /usr/share/atom
	exeinto /usr/share/atom

	cd "${OUT}"

	doexe atom libchromiumcontent.so libffmpegsumo.so

	doins -r resources
	doins -r locales
	doins version
	doins LICENSE
	doins icudtl.dat
	doins content_shell.pak

}
