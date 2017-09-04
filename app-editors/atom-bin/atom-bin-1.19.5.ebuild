# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 )
inherit flag-o-matic python-any-r1 eutils unpacker pax-utils

MY_PN="atom"

DESCRIPTION="A hackable text editor for the 21st Century."
HOMEPAGE="https://atom.io"
SRC_URI="
	amd64? ( https://github.com/${MY_PN}/${MY_PN}/releases/download/v${PV}/${MY_PN}-amd64.tar.gz -> ${MY_PN}-${PV}.tar.gz )
"

RESTRICT="primaryuri"

KEYWORDS="~amd64"
SLOT="0"
LICENSE="MIT"

IUSE="-debug"

DEPEND="${PYTHON_DEPS}
	media-fonts/inconsolata
	!!dev-util/atom-shell
	!app-editors/atom
"
RDEPEND="${DEPEND}
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

QA_PRESTRIPPED="
	/usr/share/${MY_PN}/${MY_PN}
	/usr/share/${MY_PN}/chromedriver/chromedriver
	/usr/share/${MY_PN}/libnode.so
	/usr/share/${MY_PN}/libffmpeg.so
	/usr/share/${MY_PN}/libnotify.so.4
	/usr/share/${MY_PN}/libchromiumcontent.so
	/usr/share/${MY_PN}/libgcrypt.so.11
	/usr/share/${MY_PN}/resources/app/node_modules/symbols-view/vendor/ctags-linux
	/usr/share/${MY_PN}/resources/app/node_modules/dugite/git/libexec/git-core/git-lfs
"

ARCH=$(getconf LONG_BIT)

[[ ${ARCH} == "64" ]] && S="${WORKDIR}/${MY_PN}-${PV}-amd64"

pkg_setup() {
	python-any-r1_pkg_setup
}

src_prepare() {
	eapply_user
}

src_install() {
	pax-mark m ${MY_PN}

	insinto /usr/share/${MY_PN}
	doins -r .
	doicon ${MY_PN}.png
	insinto /usr/share/doc/${MY_PN}
	newins resources/LICENSE.md copyright
	newbin "${FILESDIR}/${PN}" ${MY_PN}
	insinto /usr/share/lintian/overrides
	newins "${FILESDIR}/${PN}-lintian" ${MY_PN}
	dosym /usr/share/${MY_PN}/resources/app/apm/bin/apm /usr/bin/apm

	# Fixes permissions
	fperms +x /usr/bin/${MY_PN}
	fperms +x /usr/share/${MY_PN}/${MY_PN}
	fperms +x /usr/share/${MY_PN}/resources/app/${MY_PN}.sh
	fperms +x /usr/share/${MY_PN}/resources/app/apm/bin/node
	fperms +x /usr/share/${MY_PN}/resources/app/apm/bin/npm
	fperms +x /usr/share/${MY_PN}/resources/app/apm/bin/apm
	fperms +x /usr/share/${MY_PN}/resources/app/apm/node_modules/npm/bin/node-gyp-bin/node-gyp
	fperms +x /usr/share/${MY_PN}/resources/app/node_modules/symbols-view/vendor/ctags-linux
	fperms -R +x /usr/share/${MY_PN}/resources/app/node_modules/github/bin
	fperms -R +x /usr/share/${MY_PN}/resources/app/node_modules/dugite/git/bin
	fperms -R +x /usr/share/${MY_PN}/resources/app/node_modules/dugite/git/libexec/git-core
	fperms -R +x /usr/share/${MY_PN}/resources/app/node_modules/dugite/git/libexec/git-core/mergetools

	make_desktop_entry "/usr/bin/${MY_PN} %U" "${MY_PN}" "${MY_PN}" \
		"GNOME;GTK;Utility;TextEditor;Development;" \
		"GenericName=Text Editor\nMimeType=text/plain;\nStartupNotify=true\nStartupWMClass=${MY_PN}"
}
