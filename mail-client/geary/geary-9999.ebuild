# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit git-2 vala cmake-utils gnome2-utils

DESCRIPTION="Yorba's lightweight, easy-to-use, feature-rich email client."
HOMEPAGE="http://redmine.yorba.org/projects/geary"
EGIT_REPO_URI="git://yorba.org/geary"

LICENSE=""
SLOT="0"
KEYWORDS=""

RDEPEND="
	dev-libs/libgee
	dev-libs/glib:2
	dev-libs/gmime:2.6
	=dev-libs/sqlheavy-0.1.1
	gnome-base/gnome-keyring
	x11-libs/gtk+:3
	dev-db/sqlite:3
	dev-libs/libunique:3
	net-libs/webkit-gtk:3
"
DEPEND="${RDEPEND}
	dev-lang/vala:0.16
"


DOCS=(AUTHORS MAINTAINERS)

VALA_REQUIRED_VERSION="0.16"

src_unpack() {
	git-2_src_unpack
	cd "${S}"
}

src_configure() {
	mycmakeargs="-DGSETTINGS_COMPILE=OFF -DICON_UPDATE=OFF -DDESKTOP_UPDATE=OFF"
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	base_src_install_docs
}

pkg_preinst() {
	gnome2_schemas_savelist
}

pkg_postinst() {
	gnome2_schemas_update
}

pkg_postrm() {
	gnome2_schemas_update
}

