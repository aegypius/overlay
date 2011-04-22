# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
PYTHON_DEPEND="2:2.6"
SUPPORT_PYTHON_ABIS="1"

inherit distutils bzr

DESCRIPTION="A Simple Python DAAP server."
HOMEPAGE="https://launchpad.net/spydaap"
EBZR_REPO_URI="lp:spydaap"


LICENSE="GPL"
SLOT="live"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

DEPEND="dev-python/setuptools"
RDEPEND="${DEPEND}"

src_unpack() {
	bzr_src_unpack;
}
