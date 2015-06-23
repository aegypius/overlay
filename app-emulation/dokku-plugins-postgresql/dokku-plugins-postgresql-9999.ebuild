# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="PostgreSQL plugin for Dokku"
HOMEPAGE="https://github.com/Kloadut/dokku-pg-plugin"
SRC_URI=""

EGIT_REPO_URI="https://github.com/Kloadut/dokku-pg-plugin"
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

pkg_setup() {
	$(gpasswd --add portage docker> /dev/null)
}

src_compile() {
	docker build -t kloadut/postgresql github.com/Kloadut/dokku-pg-dockerfiles
}

src_install() {
	exeinto /var/lib/dokku/plugins/mariadb
	doexe commands
	doexe pre-release
}
