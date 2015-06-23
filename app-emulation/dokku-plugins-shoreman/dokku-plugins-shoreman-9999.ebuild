# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Run all process types with dokku"
HOMEPAGE="https://github.com/statianzo/dokku-shoreman"
SRC_URI=""

EGIT_REPO_URI="https://github.com/statianzo/dokku-shoreman.git"
if [[ ${PV} == *9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64"
	EGIT_COMMIT="v${PV}"
fi

inherit git-2 user

LICENSE="MIT"
SLOT="0"
IUSE=""

DEPEND="
	app-emulation/docker
"
RDEPEND="${DEPEND}"

src_unpack() {
	git-2_src_unpack
}

src_install() {
	exeinto /var/lib/dokku/plugins/shoreman
	doexe post-release
}
