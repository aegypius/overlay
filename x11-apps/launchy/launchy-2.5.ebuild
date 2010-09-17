# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils multilib qt4

DESCRIPTION="Launchy is a free utility designed to help you forget about your start menu, the icons on your desktop, and even your file manager."
HOMEPAGE="http://www.launchy.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="gnome"

DEPEND="x11-libs/qt-core:4
		x11-libs/qt-gui:4
		dev-libs/boost"
RDEPEND="${DEPEND}"

# TODO : 
#  - Patch source to store database and preferences in ~/.config/launchy/
#  - Make some USE to enable/disable plugins
#

src_configure() {
   for f in platform/unix plugins/{runner,weby,calcy,gcalc} ; do
      cd "${S}/${d}"
      SKINS_PATH="\\\"/usr/share/launchy/skins\\\"" \
      PLUGINS_PATH="\\\"/usr/$(get_libdir)/launchy/plugins\\\"" \
      PLATFORMS_PATH="\\\"/usr/$(get_libdir)/launchy\\\"" \
      DESKTOP_PATH="\\\"/usr/share/applications\\\"" \
      ICON_PATH="\\\"/usr/share/pixmaps\\\"" \
      eqmake4 *.pro
   done
}

src_compile() {
   for f in platform/unix plugins/{runner,weby,calcy,gcalc} ; do
      cd "${S}/${d}"
      SKINS_PATH="\\\"/usr/share/launchy/skins\\\"" \
      PLUGINS_PATH="\\\"/usr/$(get_libdir)/launchy/plugins\\\"" \
      PLATFORMS_PATH="\\\"/usr/$(get_libdir)/launchy\\\"" \
      DESKTOP_PATH="\\\"/usr/share/applications\\\"" \
      ICON_PATH="\\\"/usr/share/pixmaps\\\"" \
      emake -f Makefile || die "emake failed"
   done
}


src_install() {

   newbin release/launchy launchy

   insinto /usr/$(get_libdir)/launchy
   doins release/libplatform_unix.so

   insinto /usr/$(get_libdir)/launchy/plugins
   doins release/plugins/*.so

   insinto /usr/$(get_libdir)/launchy/plugins/icons
   doins plugins/runner/runner.png plugins/weby/weby.png plugins/calcy/calcy.png

   insinto /usr/share/launchy
   doins -r skins

   domenu linux/launchy.desktop
   newicon "misc/Launchy Icon/launchy_icon.png" launchy.png

   dodoc Readme.*
}
