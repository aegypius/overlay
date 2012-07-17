# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils

DESCRIPTION="The Leading PHP Editor"
SRC_URI="
	amd64? ( http://downloads.zend.com/studio-eclipse/$PV/ZendStudio-$PV-x86_64.tar.gz )
	x86? ( http://downloads.zend.com/studio-eclipse/$PV/ZendStudio-$PV-x86.tar.gz )
"

HOMEPAGE="http://www.zend.com/en/products/studio/"

KEYWORDS="-* ~amd64 ~x86"
SLOT="0"
#LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"

S="${WORKDIR}/${MY_PN}"

RDEPEND="
	virtual/jre
	media-libs/libpng:1.2
	<net-misc/curl-7.25.0"

src_unpack() {
	unpack ${A}
}

src_install() {
	declare ZEND_STUDIO_HOME=/opt

	# Install zend-studio in /opt
	dodir ${ZEND_STUDIO_HOME}
	mv "${S}/ZendStudio/" "${D}"${ZEND_STUDIO_HOME}/${PN} || die

	dosym ${ZEND_STUDIO_HOME}/${PN}/ZendStudio /usr/bin/ZendStudio
}

