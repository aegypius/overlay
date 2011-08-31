# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils

MY_URL="http://dl.google.com/linux/direct"
MY_PKG="${PN}-beta_current_i386.deb"

DESCRIPTION="Google Music Manager is a simple application for adding the music files on your computer to your Music library."
HOMEPAGE="http://music.google.com"
SRC_URI="x86? ( ${MY_URL}/${MY_PKG} )
	amd64? ( ${MY_URL}/${MY_PKG/i386/amd64} )"

LICENSE="google-musicmanager Apache-2.0 MIT LGPL gSOAP BSD MPL openssl ZLIB"
SLOT="0"
KEYWORDS="-*"
IUSE=""

RESTRICT="strip mirror"

DEPEND=">=sys-libs/glibc-2.11
	>=dev-libs/expat-1.95.8
	>=media-libs/flac-1.2.1
	>=media-libs/fontconfig-2.8.0
	>=media-libs/freetype-2.2.1
	media-libs/libid3tag
	>=sys-devel/gcc-4.1.1
	>=dev-libs/glib-2.12.0
	>=net-dns/libidn-1.13
	>=media-libs/libogg-1.0.0
	>=x11-libs/qt-core-4.6.1
	>=x11-libs/qt-gui-4.5.3
	>=media-libs/libvorbis-1.1.2
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-misc/xdg-utils"

RDEPEND="${DEPEND}"

INSTALL_BASE="/opt/google/musicmanager"

pkg_nofetch() {
	einfo "This version is no longer available from Google."
	einfo "Note that Gentoo cannot mirror the distfiles due to license reasons, so we have to follow the bump."
	einfo "Please file a version bump bug on http://bugs.gentoo.org (search existing bugs for ${PN} first!)."
}

src_unpack() {
	ar x ${DISTDIR}/${A}
	unpack ./data.tar.lzma || die
}

src_install() {
	dodir "${INSTALL_BASE}"
	insinto "${INSTALL_BASE}"
	doins opt/google/musicmanager/config.xml
	doins opt/google/musicmanager/lib*
	doins opt/google/musicmanager/minidump_upload
	doins opt/google/musicmanager/product_logo_*.png

	insinto /usr/share/pixmaps/
	newins opt/google/musicmanager/product_logo_32.xpm google-musicmanager.xpm

	dosym /opt/google/musicmanager/google-musicmanager /opt/bin/

	exeinto /opt/google/musicmanager/
	doexe opt/google/musicmanager/google-musicmanager
	doexe opt/google/musicmanager/MusicManager

	make_desktop_entry "${PN}" "Google Music Manager" "${PN}" "AudioVideo;Audio;Player;Music"
}
