# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI=4

inherit eutils vala

MY_P="nuvolaplayer"

DESCRIPTION="Cloud music integration for your Linux desktop"
HOMEPAGE="https://launchpad.net/nuvola-player"
SRC_URI="https://launchpad.net/${PN}/2.0.x/${PV}/+download/${MY_P}-${PV}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug"

VALA_REQUIRED_VERSION="0.16"

RDEPEND="www-plugins/adobe-flash
        "
DEPEND="${RDEPEND}
        >=dev-lang/vala-0.16
        dev-util/intltool
        >=net-libs/libsoup-2.34
        >=x11-libs/gtk+-3.0
        >=dev-libs/libunique-0.9
        >=dev-libs/libgee-0.5
        >=net-libs/webkit-gtk-1.2"

S="${WORKDIR}/${MY_P}-${PV}/"

src_configure(){
    ./waf configure --no-unity-quick-list --no-svg-optimization --prefix=${D}/usr
}

src_compile(){
    ./waf build
}

src_install(){
    ./waf install
    make_desktop_entry "/usr/bin/${MY_P}" "Nuvola Player" "/usr/share/icons/hicolor/64x64/apps/${MY_P}.png" "AudioVideo;Audio;Network;"
}

pkg_postinst() {
    rm /usr/share/applications/nuvolaplayer.desktop
}
