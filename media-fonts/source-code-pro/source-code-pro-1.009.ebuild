# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit font

MY_P="SourceCodePro_FontsOnly-${PV}"

DESCRIPTION="Source Code Pro is a set of OpenType fonts that have been designed
to work well in user interface (UI) environments."
HOMEPAGE="https://github.com/adobe/Source-Code-Pro"
SRC_URI="https://github.com/downloads/adobe/Source-Code-Pro/${MY_P}.zip" 

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

# This ebuild does not install any binaries
RESTRICT="binchecks strip"

DEPEND="app-arch/unzip"
RDEPEND="media-libs/fontconfig"

S="${WORKDIR}/${MY_P}"
FONT_S="${S}"
FONT_SUFFIX="otf ttf"

src_install() {
	font_src_install
	dohtml *.html
}
