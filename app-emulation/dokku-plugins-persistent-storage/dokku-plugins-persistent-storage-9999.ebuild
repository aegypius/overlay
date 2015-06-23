# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Basic persistent storage for dokku"
HOMEPAGE="https://github.com/dyson/dokku-persistent-storage"
SRC_URI=""

EGIT_REPO_URI="https://github.com/dyson/dokku-persistent-storage"
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
	>app-emulation/dokku-0.2
"
RDEPEND="${DEPEND}"

src_unpack() {
	git-2_src_unpack
}

src_install() {
	exeinto /var/lib/dokku/plugins/persistent-storage
	doexe docker-args
}
