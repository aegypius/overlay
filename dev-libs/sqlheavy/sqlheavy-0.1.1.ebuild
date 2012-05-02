# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit autotools git-2

DESCRIPTION="GObject SQLite wrapper"
HOMEPAGE="http://code.google.com/p/sqlheavy/"
EGIT_REPO_URI="git://gitorious.org/${PN}/${PN}.git"
EGIT_BRANCH="0.1"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS=""
IUSE="doc examples"

RDEPEND=">=dev-libs/glib-2.22:2
	>=dev-db/sqlite-3.6.20:3
	>=x11-libs/gtk+-2.24:2"
DEPEND="${RDEPEND}
	dev-lang/vala:0.16
	dev-util/pkgconfig
	doc? ( dev-util/valadoc )"

DOCS=( AUTHORS NEWS README )

src_prepare() {
	sed -i -e "/examples/d" Makefile.am # don't compile examples
	eautoreconf
}

src_configure() {
	VALAC=$(type -p valac-0.16) \
	econf \
		--disable-static \
		$(use_enable doc valadoc)
}

src_install() {
	default
	find "${ED}" -name "*.la" -delete || die
	docinto examples
	use examples && dodoc examples/*.vala
}
