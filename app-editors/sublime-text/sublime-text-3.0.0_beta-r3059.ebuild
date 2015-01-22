# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils versionator

MY_V=$(get_major_version)
MY_P="sublime_text"
MY_B=${PR/r/}
MY_T=/opt/${PN}-$(get_major_version)
S="${WORKDIR}/sublime_text_3"

DESCRIPTION="Sublime Text is a sophisticated text editor for code, html and prose"
HOMEPAGE="http://www.sublimetext.com"

COMMON_URI="http://c758482.r82.cf2.rackcdn.com"
SRC_URI="
	amd64?			( ${COMMON_URI}/${MY_P}_${MY_V}_build_${MY_B}_x64.tar.bz2 )
	x86?			  ( ${COMMON_URI}/${MY_P}_${MY_V}_build_${MY_B}_x32.tar.bz2 )
"

LICENSE="SublimeText"
SLOT="3"
KEYWORDS="~amd64 ~x86"
RESTRICT="strip mirror"

RDEPEND="media-libs/libpng:1.2
		>=x11-libs/gtk+-2.24.8-r1:2"

QA_PRESTRIPPED="
		${MY_T}/sublime_text
		${MY_T}/plugin_host
		${MY_T}/crash_reporter"

src_prepare() {

	# Tweaking desktop entry
	sed -i -e s@/opt/sublime_text/@${MY_T}/@ sublime_text.desktop || die "Sed failed!"
	sed -i -e s@Icon=sublime-text@Icon=${MY_T}/Icon/256x256/sublime-text.png@ sublime_text.desktop || die "Sed failed!"
	sed -i -e s@OnlyShowIn=Unity\;@@ sublime_text.desktop || die "Sed failed!"

}

src_install() {

	insinto ${MY_T}
	into	${MY_T}
	exeinto ${MY_T}
	doins -r "Icon"
	doins -r "Packages"
	doins "changelog.txt"
	doexe "crash_reporter"
	doins "sublime_plugin.py"
	doins "sublime.py"
	doins "python3.3.zip"
	doexe "plugin_host"
	doexe "sublime_text"
	dosym "${MY_T}/sublime_text" /usr/bin/sublime${SLOT}
	insinto /usr/share/applications
	doins "sublime_text.desktop"

}
