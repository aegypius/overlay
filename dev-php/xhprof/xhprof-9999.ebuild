# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-php/xhprof/xhprof-0.9.2.ebuild,v 1.3 2013/03/05 10:09:34 olemarkus Exp $

EAPI="5"

PHP_EXT_NAME="xhprof"
PHP_EXT_INI="yes"
PHP_EXT_ZENDEXT="no"
PHP_EXT_S="${WORKDIR}/xhprof-${PV}/extension"
USE_PHP="php5-3 php5-4"

inherit php-ext-pecl-r2 git-2

DESCRIPTION="A Hierarchical Profiler for PHP"
HOMEPAGE="https://github.com/facebook/xhprof/"
SRC_URI=""
EGIT_PROJECT="xhprof"
EGIT_REPO_URI="git://github.com/facebook/xhprof.git"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="php_targets_php5-3 php_targets_php5-4"

src_unpack() {
	git-2_src_unpack
	local slot orig_s="${PHP_EXT_S}"
	for slot in $(php_get_slots); do
		cp -r "${orig_s}" "${WORKDIR}/${slot}" || die "Failed to copy source ${orig_s} to PHP target directory"
		cd "${WORKDIR}/${slot}"
	done
}
