# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Meta ebuild to pull in dokku plugins"
HOMEPAGE="https://github.com/aegypius/overlay"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="amd64"
IUSE="mariadb mongodb postgresql redis supervisord rebuild"

RDEPEND="
	app-emulation/dokku
	mariadb? ( app-emulation/dokku-plugin-mariadb )
	mongodb? ( app-emulation/dokku-plugin-mongodb )
	postgresql? ( app-emulation/dokku-plugin-postgresql )
	redis? ( app-emulation/dokku-plugin-redis )
	supervisord? ( app-emulation/dokku-plugin-supervisord )
	rebuild? ( app-emulation/dokku-plugin-rebuild )
"
