# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI=4

inherit eutils versionator vala

MY_P="nuvolaplayer"

MY_PV_MILESTONE=$(version_format_string '$1.$2.x')
MY_PV=$(version_format_string '$1.$2.$3')

DESCRIPTION="Cloud music integration for your Linux desktop"
HOMEPAGE="https://launchpad.net/nuvola-player"
SRC_URI="https://launchpad.net/${PN}/${MY_PV_MILESTONE}/${MY_PV}/+download/${MY_P}-${PV}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+dock-manager +mpris +cli +media-keys +lastfm +notifications +lyrics experimental debug"
RESTRICT="mirror"

VALA_MIN_API_VERSION="0.8"

RDEPEND="www-plugins/adobe-flash
        "
DEPEND="${RDEPEND}
        >=dev-lang/vala-${VALA_MIN_API_VERSION}
        dev-util/intltool
        >=dev-libs/libgee-0.6
        notifications? ( >=x11-libs/libnotify-0.4 )
        >=x11-libs/gtk+-3.4
        >=net-libs/libsoup-2.38:2.4
        lastfm?        ( >=dev-libs/json-glib-0.7 )
        >=dev-libs/libunique-0.9
        >=net-libs/webkit-gtk-1.8
        >=dev-libs/glib-2.32
"

S="${WORKDIR}/${MY_P}-${PV}/"

src_configure(){
    waf_options="--no-unity-quick-list \
        --no-svg-optimization \
        --$(usex dock-manager     dock-manager     no-dock-manager) \
        --$(usex mpris            mpris            no-mpris) \
        --$(usex cli              nuvola-client    no-nuvola-client) \
        --$(usex media-keys       media-keys       no-media-keys) \
        --$(usex lastfm           lastfm           no-lastfm) \
        --$(usex notifications    notifications    no-notifications) \
        --$(usex lyrics           lyrics-fetching  no-lyrics-fetching) \
        --$(usex experimental     experimental     no-experimental) \
        --$(usex debug            debug            no-debug) \
        --prefix=${D}/usr
    "
    ./waf configure ${waf_options} || die "Configuration failed"
}

src_compile(){
    ./waf build || die "Compilation failed"
}

src_install(){
    ./waf install || die "Installation failed"
	rm "${D}/usr/share/applications/nuvolaplayer.desktop";
    make_desktop_entry "/usr/bin/${MY_P}" "Nuvola Player" "/usr/share/icons/hicolor/64x64/apps/${MY_P}.png" "AudioVideo"
}

