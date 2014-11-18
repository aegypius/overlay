# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Pulls service details out of Consul and spits out config files"
HOMEPAGE="https://github.com/octohost/octoconfig"

USE_RUBY="ruby20"

inherit multilib ruby-fakegem

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

ruby_add_rdepend "
	=dev-ruby/gli-2.11.0
	dev-ruby/json
"

IUSE=""
