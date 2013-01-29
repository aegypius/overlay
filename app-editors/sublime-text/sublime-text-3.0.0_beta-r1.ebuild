# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils versionator

MY_V=$(get_version_component_range 1)
MY_P="sublime_text"
MY_B="3006"
S="${WORKDIR}/sublime_text_3"

DESCRIPTION="Sublime Text is a sophisticated text editor for code, html and prose"
HOMEPAGE="http://www.sublimetext.com"
COMMON_URI="http://c758482.r82.cf2.rackcdn.com"
SRC_URI="amd64? ( ${COMMON_URI}/${MY_P}_${MY_V}_build_${MY_B}_x64.tar.bz2 )
         x86?   ( ${COMMON_URI}/${MY_P}_${MY_V}_build_${MY_B}_x32.tar.bz2 )"
LICENSE="Sublime"
SLOT="0"
KEYWORDS=""
IUSE=""
RESTRICT="mirror"

RDEPEND="media-libs/libpng:1.2
	     >=x11-libs/gtk+-2.24.8-r1:2"

src_install() {
	insinto /opt/${PN}
	into /opt/${PN}
	exeinto /opt/${PN}
	doins -r "Icon"
	doins -r "Packages"
	doins "sublime_plugin.py"
	doins "sublime.py"
	doins "python3.3.zip"
	doexe "plugin_host"
	doexe "sublime_text"
	dosym "/opt/${PN}/sublime_text" /usr/bin/sublime
	make_desktop_entry "/usr/bin/sublime %U" "Sublime Text Editor"	"/opt/${PN}/Icon/256x256/sublime_text.png" "Application;TextEditor"

}
