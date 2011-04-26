# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils subversion

DESCRIPTION="A standalone skill monitoring application for EVE Online"
HOMEPAGE="http://gtkevemon.battleclinic.com"
SRC_URI=""
ESVN_REPO_URI="svn://svn.battleclinic.com/GTKEVEMon/trunk/${PN}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND="dev-cpp/gtkmm:2.4
	dev-libs/libxml2"
DEPEND="${DEPEND}
	dev-util/pkgconfig"

src_prepare() {
	sed -e 's:Categories=Game;$:Categories=Game;RolePlaying;GTK;:' \
		-i icon/${PN}.desktop || die "sed failed"
}

src_install() {
	dobin src/${PN} || die "dobin failed"
	dodoc CHANGES README TODO || die "dodoc failed"
	cd icon
	doicon ${PN}.png || die "doicon failed"
	domenu ${PN}.desktop || die "domenu failed"
}
