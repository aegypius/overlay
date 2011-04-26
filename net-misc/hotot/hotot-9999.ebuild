# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="3"
PYTHON_DEPEND="2"

inherit eutils distutils mercurial

DESCRIPTION="
Hotot, is a lightweight & open source Microblogging Client, coding using Python language and designed for Linux."

HOMEPAGE="http://www.hotot.org/"
EHG_REPO_URI="https://hotot.googlecode.com/hg/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

S="${WORKDIR}/hg"

RDEPEND="
   dev-python/pywebkitgtk
   dev-python/notify-python
   dev-python/keybinder
   dev-python/python-distutils-extra
"

src_compile() {
   distutils_src_compile
}

src_install() {
   distutils_src_install
}
