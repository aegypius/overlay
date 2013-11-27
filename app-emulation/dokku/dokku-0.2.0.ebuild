# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Docker powerered mini-Heroku"
HOMEPAGE="https://github.com/progrium/dokku"
SRC_URI=""

EGIT_REPO_URI="git://github.com/progrium/dokku"
if [[ ${PV} == *9999 ]]; then
    KEYWORDS=""
else
    KEYWORDS="~amd64"
    EGIT_COMMIT="v${PV}"
fi

inherit git-2 user

LICENSE="MIT"
SLOT="0"
IUSE="nginx-vhosts"

DEPEND="
    app-emulation/docker
    app-shells/pluginhook
    app-shells/sshcommand
"
RDEPEND="${DEPEND}
    app-shells/bash
"

src_unpack() {
    git-2_src_unpack
}

src_prepare() {
    rm plugins/WARNING

    # Home dir skeleton
    mkdir -p home
    echo ${PV}            > home/VERSION
}

src_compile() {
    true
}

src_install() {
    exeinto /usr/bin/
    doexe dokku

    exeinto /var/lib/${PN}/plugins/config
    doexe plugins/config/commands
    doexe plugins/config/backup-import
    doexe plugins/config/backup-export

    exeinto /var/lib/${PN}/plugins/00_dokku-standard
    doexe plugins/00_dokku-standard/pre-delete
    doexe plugins/00_dokku-standard/commands
    doexe plugins/00_dokku-standard/install
    doexe plugins/00_dokku-standard/post-delete
    doexe plugins/00_dokku-standard/backup-import
    doexe plugins/00_dokku-standard/backup-export

    exeinto /var/lib/${PN}/plugins/backup
    doexe plugins/backup/commands

    exeinto /var/lib/${PN}/plugins/git
    doexe plugins/git/commands
    doexe plugins/git/backup-import

    if use nginx-vhosts; then
        ewarn "Nginx plugin has not been fully tested for gentoo"
        exeinto /var/lib/${PN}/plugins/nginx-vhosts
        doexe plugins/nginx-vhosts/commands
        doexe plugins/nginx-vhosts/install
        doexe plugins/nginx-vhosts/post-deploy
        doexe plugins/nginx-vhosts/post-delete
        doexe plugins/nginx-vhosts/backup-import
        doexe plugins/nginx-vhosts/backup-export
    fi

    insinto /home/${PN}
    doins home/VERSION
}

pkg_postinst() {
    sshcommand create ${PN} /usr/bin/${PN} 2>& 1> /dev/null
    gpasswd -a ${PN} docker
    elog ""

    elog " *************************************************** "
    elog " Dokku ships with a pre-built version of version of  "
    elog " the buildstep component by default but this package "
    elog " does not set them up.                               "
    elog "                                                     "
    elog " To do so run :                                      "
    elog "   curl https://s3.amazonaws.com/progrium-dokku/progrium_buildstep_79cf6805cf.tgz | gunzip -cd | docker import - progrium/buildstep"
    elog ""
    elog " *************************************************** "
}
