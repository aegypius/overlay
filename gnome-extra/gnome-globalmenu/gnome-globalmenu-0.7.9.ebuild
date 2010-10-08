# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=1

inherit gnome2

DESCRIPTION="Global menubar applet for Gnome2."
HOMEPAGE="http://code.google.com/p/gnome2-globalmenu/"
SRC_URI="http://gnome2-globalmenu.googlecode.com/files/${P/_p/_}.tar.bz2"

S="${WORKDIR}/${P/_p/_}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="gnome test xfce"

RDEPEND="dev-libs/glib:2
   gnome-base/gconf:2
   gnome-base/gnome-menus
   x11-libs/gtk+:2
   x11-libs/libX11
   x11-libs/libwnck
   gnome? (
      gnome-base/gnome-panel
      x11-libs/libnotify )
   xfce? (
      xfce-base/xfce4-panel )"

DEPEND="${RDEPEND}
   dev-util/intltool
   dev-util/pkgconfig
   >=dev-lang/vala-0.7.7"

pkg_setup() {
   G2CONF="${G2CONF}
      --without-gir
      --docdir=/usr/share/doc/${PF}
      $(use_enable test tests)
      $(use_with gnome gnome-panel)
      $(use_with xfce xfce4-panel)"
}

pkg_postinst() {
   gnome2_pkg_postinst

   ewarn "DO NOT report bugs to Gentoo's bugzilla"
   einfo "Please report all bugs to http://gnome2-globalmenu.googlecode.com/issues"
   einfo "Thank you"
}