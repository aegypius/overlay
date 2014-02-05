# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-2

DESCRIPTION="Unclutter your .profile"
HOMEPAGE="http://direnv.net"
SRC_URI=""

LICENSE=""
SLOT="0"

EGIT_REPO_URI="git://github.com/zimbatm/direnv"

if [[ $PV = *9999 ]]; then
	KEYWORDS=""
else 
	KEYWORDS="~amd64"
	EGIT_COMMIT="v${PV}"
fi 

IUSE=""

DEPEND="
	dev-lang/go
"
RDEPEND="${DEPEND}"

pkg_postinst() {
	einfo "To enable direnv extension you must do has following"
	einfo 
	einfo " For Bash, add the following line at the end of your ~/.bashrc :"
	einfo '   eval "$(direnv hook bash)"'
	einfo 
	einfo " For Zsh, add the following line at the end of your ~/.zshrc :"
	einfo '   eval "$(direnv hook zsh)"'
	einfo 
	einfo " For Fish, add the following line at the end of your ~/config/fish/config.fish :"
	einfo '   eval (direnv hook fish)'
}
