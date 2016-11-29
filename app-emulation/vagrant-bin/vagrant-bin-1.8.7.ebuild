# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

MY_PN=${PN/-bin/}
inherit unpacker eutils

DESCRIPTION="Tool for building and distributing virtual machines"
HOMEPAGE="http://vagrantup.com/"
SRC_URI="https://releases.hashicorp.com/vagrant/${PV}/${MY_PN}_${PV}_x86_64.deb"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

S="${WORKDIR}/opt/${MY_PN}"

DEPEND=""
RDEPEND="${DEPEND}
	app-arch/libarchive
	net-misc/curl
"

RESTRICT="mirror"

src_unpack() {
	unpack_deb ${A}
}

src_install() {
	local dir="/opt/${MY_PN}"
	dodir ${dir}
	cp -ar ./* "${ED}${dir}" || die "copy files failed"

	make_wrapper "${MY_PN}" "${dir}/bin/${MY_PN}"
}
