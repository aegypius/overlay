# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit perl-module systemd

MY_PN="FusionInventory-Agent"
DESCRIPTION="Powerful inventory and package deployment system"
HOMEPAGE="http://www.fusioninventory.org/"
SRC_URI="https://github.com/fusioninventory/${MY_PN}/releases/download/${PV}/${MY_PN}-${PV}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RESTRICT="primaryuri"

DEPEND="
	sys-apps/dmidecode
	dev-perl/File-Which
	dev-perl/IO-Socket-SSL
	dev-perl/UNIVERSAL-require
	dev-perl/XML-TreePP
	dev-perl/Net-IP
	dev-perl/Text-Template
"
RDEPEND="${DEPEND}"

MY_P=${MY_PN}-${PV}
S=${WORKDIR}/${MY_P}
myconf="SYSCONFDIR=/etc/fusioninventory"

src_install() {
	emake install
	# dodir /usr/lib/fusioninventory/
	systemd_dounit "$S/contrib/unix/fusioninventory-agent.service"
	systemd_enable_service multi-user.target fusioninventory-agent.service
}

pkg_postinst() {
	elog "To configure Fusioninventory-agent,"
	elog "edit the file /etc/fusioninventory/agent.cfg,"
	elog "read the following web page:"
	elog "http://www.fusioninventory.org/documentation/agent/configuration/"
}
