# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit gnome2-utils git-2

DESCRIPTION="gnome-shell extension to remove the Accessibility icon from the panel"
HOMEPAGE="https://github.com/ecoleman/noa11y-colemando.com"
EGIT_REPO_URI="https://github.com/ecoleman/noa11y-colemando.com"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND=">=gnome-base/gnome-desktop-3:3"
DEPEND="${RDEPEND}"


src_configure() {
   :
}

src_compile()   {
   :
}

src_install()   {
   dodir -p /usr/share/gnome-shell/extensions/noa11y@colemando.com
   insinto /usr/share/gnome-shell/extensions/noa11y@colemando.com
   doins extension.js
   doins metadata.json
}
