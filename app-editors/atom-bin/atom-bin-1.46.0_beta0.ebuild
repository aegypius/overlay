# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )
inherit flag-o-matic python-any-r1 eutils unpacker pax-utils

MY_PN="atom"
MY_PV=${PV//_beta/-beta}

DESCRIPTION="A hackable text editor for the 21st Century."
HOMEPAGE="https://atom.io"
SRC_URI="
	amd64? ( https://github.com/${MY_PN}/${MY_PN}/releases/download/v${MY_PV}/${MY_PN}-amd64.tar.gz -> ${MY_PN}-${PV}.tar.gz )
"

RESTRICT="primaryuri"

KEYWORDS="~amd64"
SLOT="beta"
LICENSE="MIT"

IUSE="-debug"

DEPEND="${PYTHON_DEPS}
	media-fonts/inconsolata
	dev-libs/openssl-compat:1.0.0
	!!dev-util/atom-shell
	!app-editors/atom
	!app-editors/atom-bin:0
"
RDEPEND="${DEPEND}
	x11-libs/gtk+:2
	x11-libs/libnotify
	x11-libs/libXScrnSaver
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
	/usr/share/${MY_PN}/resources/app/apm/node_modules/keytar/build/Release/keytar.node
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/symbols-view/vendor/ctags-linux
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/dugite/git/libexec/git-core/git-lfs
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/dugite/git/libexec/git-core/git-imap-send
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/dugite/git/libexec/git-core/git-daemon
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/dugite/git/libexec/git-core/git-credential-store
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/dugite/git/libexec/git-core/git-credential-cache--daemon
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/dugite/git/libexec/git-core/git-http-backend
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/dugite/git/libexec/git-core/git-fast-import
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/dugite/git/libexec/git-core/git-shell
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/dugite/git/libexec/git-core/git
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/dugite/git/libexec/git-core/git-sh-i18n--envsubst
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/dugite/git/libexec/git-core/git-http-push
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/dugite/git/libexec/git-core/git-credential-cache
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/dugite/git/libexec/git-core/git-http-fetch
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/dugite/git/libexec/git-core/git-remote-http
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/dugite/git/bin/git
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/tree-sitter-bash/build/Release/tree_sitter_bash_binding.node
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/keytar/build/Release/keytar.node
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/tree-sitter-ruby/build/Release/tree_sitter_ruby_binding.node
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/@atom/fuzzy-native/build/Release/fuzzy-native.node
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/@atom/watcher/build/Release/watcher.node
	/usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/vscode-ripgrep/bin/rg
"

pkg_setup() {
	python-any-r1_pkg_setup
}

src_unpack() {
	unpack ${A}

	ARCH=$(getconf LONG_BIT)

	[[ ${SLOT} == "beta" ]] && CHANNEL="-beta"
	[[ ${ARCH} == "64" ]] && mv "${WORKDIR}/${MY_PN}${CHANNEL}-${MY_PV}-amd64" "${WORKDIR}/${PN}-${PV}"
}

src_prepare() {
	eapply_user
}

src_install() {
	pax-mark m ${MY_PN}

	insinto /usr/share/${MY_PN}
	doins -r .
	doicon ${MY_PN}.png
	insinto /usr/share/doc/${PN}-${PV}
	newins resources/LICENSE.md copyright
	newbin "${FILESDIR}/${PN}" ${MY_PN}
	insinto /usr/share/lintian/overrides
	newins "${FILESDIR}/${PN}-lintian" ${MY_PN}
	dosym ../share/${MY_PN}/resources/app/apm/bin/apm /usr/bin/apm

	# Fixes permissions
	fperms +x /usr/bin/${MY_PN}
	fperms +x /usr/share/${MY_PN}/${MY_PN}
	fperms +x /usr/share/${MY_PN}/resources/app/${MY_PN}.sh
	fperms +x /usr/share/${MY_PN}/resources/app/apm/bin/node
	fperms +x /usr/share/${MY_PN}/resources/app/apm/bin/npm
	fperms +x /usr/share/${MY_PN}/resources/app/apm/bin/apm
	fperms +x /usr/share/${MY_PN}/resources/app/apm/node_modules/.bin/npm
	fperms +x /usr/share/${MY_PN}/resources/app/apm/node_modules/npm/bin/node-gyp-bin/node-gyp
	fperms +x /usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/symbols-view/vendor/ctags-linux
	fperms -R +x /usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/github/bin
	fperms -R +x /usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/dugite/git/bin
	fperms -R +x /usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/vscode-ripgrep/bin
	fperms -R +x /usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/dugite/git/libexec/git-core
	fperms -R +x /usr/share/${MY_PN}/resources/app.asar.unpacked/node_modules/dugite/git/libexec/git-core/mergetools

	make_desktop_entry "/usr/bin/${MY_PN} %U" "${MY_PN}" "${MY_PN}" \
		"GNOME;GTK;Utility;TextEditor;Development;" \
		"GenericName=Text Editor\nMimeType=text/plain;\nStartupNotify=true\nStartupWMClass=${MY_PN}"
}
