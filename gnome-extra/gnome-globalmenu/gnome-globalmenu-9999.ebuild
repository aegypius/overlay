# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit autotools eutils gnome2

if [[ ${PV} == "9999" ]]; then
   ESVN_REPO_URI="http://gnome2-globalmenu.googlecode.com/svn/trunk/"
   SRC_URI=""
   inherit subversion
else
   MY_P=${P/_p/_}
   S="${WORKDIR}/${MY_P}"
   SRC_URI="http://gnome2-globalmenu.googlecode.com/files/${MY_P}.tar.bz2"
   KEYWORDS="~amd64"
fi

DESCRIPTION="Global menubar applet for Gnome2."
HOMEPAGE="http://code.google.com/p/gnome2-globalmenu/"

LICENSE="GPL-2"
SLOT="0"
IUSE="gnome test xfce"
KEYWORDS="~x86 ~amd64"

# XXX: vala dependency raised for build issues
RDEPEND=">=x11-libs/gtk+-2.10.0
   >=dev-libs/glib-2.10.0
   >=gnome-base/gconf-2
   >=x11-libs/libwnck-2.16.0
   >=gnome-base/gnome-menus-2.16.0
   gnome? (
      >=gnome-base/gnome-panel-2.16.0
      >=x11-libs/libnotify-0.4.4 )
   xfce? (
      >=xfce-base/xfce4-panel-4.4.3 )
   >=x11-libs/libX11-1.1.0"

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

src_unpack() {
   if [[ ${PV} == "9999" ]]; then
      subversion_src_unpack
   else
      unpack ${A}
   fi
   cd "${S}"
}

src_prepare() {
   gnome2_src_prepare

   # INSTALL is not useful or existing depending on version
   sed 's/\(doc_DATA.*\)INSTALL/\1/' \
       -i Makefile.am || die "sed failed"

   # Fix compilation problem with --as-needed
   epatch "${FILESDIR}/${PN}-0.7.7-as-needed.patch"

   intltoolize --force --copy --automake || die "intltoolize failed"
   AT_M4DIR="autotools" eautoreconf
}

pkg_postinst() {
   gnome2_pkg_postinst

   ewarn "DO NOT report bugs to Gentoo's bugzilla"
   einfo "Please report all bugs to http://gnome2-globalmenu.googlecode.com/issues"
   einfo "Thank you"
}