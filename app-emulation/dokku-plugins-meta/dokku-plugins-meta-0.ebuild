# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Meta ebuild to pull in dokku plugins"
HOMEPAGE="https://github.com/aegypius/overlay"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="amd64"
IUSE="mariadb mongodb postgresql redis supervisord shoreman rebuild link persistent-storage"

RDEPEND="
	app-emulation/dokku
	mariadb? ( app-emulation/dokku-plugins-mariadb )
	mongodb? ( app-emulation/dokku-plugins-mongodb )
	postgresql? ( app-emulation/dokku-plugins-postgresql )
	redis? ( app-emulation/dokku-plugins-redis )
	supervisord? ( app-emulation/dokku-plugins-supervisord )
	shoreman? ( app-emulation/dokku-plugins-shoreman )
	rebuild? ( app-emulation/dokku-plugins-rebuild )
	link? ( app-emulation/dokku-plugins-link )
	persistent-storage? ( app-emulation/dokku-plugins-persistent-storage )
"
REQUIRED_USE="
	supervisord? ( !shoreman )
	shoreman? ( !supervisord )
"
