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
IUSE="+buildstep"

DEPEND="
	app-emulation/docker
	app-shells/pluginhook
	app-shells/sshcommand
"
RDEPEND="${DEPEND}
	app-shells/bash
	app-admin/sudo
"

src_unpack() {
	git-2_src_unpack
}

pkg_setup() {
	enewgroup ${PN}
	enewuser  ${PN} -1 /bin/sh /var/lib/${PN} ${PN}
	if use buildstep; then
		$(gpasswd --add portage docker > /dev/null)
	fi
}

src_prepare() {
	rm plugins/WARNING

	# Generate version file
	if [[ ${PV} == *9999 ]]; then
		echo "${EGIT_BRANCH}-$(git rev-parse --short HEAD)" > VERSION
	else
		echo ${PV} > VERSION
	fi

	# Generate HOSTNAME & VHOST files
	hostname -f > HOSTNAME
	hostname -f > VHOST

	epatch ${FILESDIR}/001-fix-rootdir.patch
	epatch ${FILESDIR}/002-use-plugin_path.patch
	epatch ${FILESDIR}/003-add-support-for-systemd.patch
}

src_compile() {
	if use buildstep; then
		docker build -t progrium/buildstep github.com/progrium/buildstep
	fi
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
	doexe plugins/00_dokku-standard/post-delete
	doexe plugins/00_dokku-standard/backup-check
	doexe plugins/00_dokku-standard/backup-import
	doexe plugins/00_dokku-standard/backup-export

	exeinto /var/lib/${PN}/plugins/backup
	doexe plugins/backup/commands

	exeinto /var/lib/${PN}/plugins/git
	doexe plugins/git/commands
	doexe plugins/git/backup-import

	exeinto /var/lib/${PN}/plugins/nginx-vhosts
	doexe plugins/nginx-vhosts/commands
	doexe plugins/nginx-vhosts/post-deploy
	doexe plugins/nginx-vhosts/post-delete
	doexe plugins/nginx-vhosts/backup-import
	doexe plugins/nginx-vhosts/backup-export

	insinto /etc/nginx/sites.d
	newins ${FILESDIR}/plugins/nginx-vhosts/nginx.conf ${PN}.conf

	insinto /etc/sudoers.d
	newins ${FILESDIR}/plugins/nginx-vhosts/sudoers.conf ${PN}

	insinto /var/lib/${PN}
	doins VERSION
	doins HOSTNAME
	doins VHOST

	keepdir /var/lib/${PN}
	fowners ${PN}:${PN} /var/lib/${PN}
	fperms	750 /var/lib/${PN}
}

pkg_postinst() {
	sshcommand create ${PN} /usr/bin/${PN} 2>& 1> /dev/null
	$(gpasswd --add ${PN} docker > /dev/null)

	grep -Fxq '#includedir /etc/sudoers.d' /etc/sudoers
	if [[ $? -eq 1 ]]; then
		ewarn ""
		ewarn "nginx-vhosts plugin requires to reload nginx after each"
		ewarn "deployment. Please update your sudoers config with:"
		ewarn ""
		ewarn "  echo '#includedir /etc/sudoers.d' >> /etc/sudoers"
		ewarn ""
	fi

	grep -Fq 'include /etc/nginx/sites.d/*.conf;' /etc/nginx/nginx.conf
	if  [[ $? -eq 1 ]]; then
		ewarn ""
		ewarn "nginx-vhost plugin requires to load dokku configuration."
		ewarn "Please add the following line to your /etc/nginx/nginx.conf"
		ewarn "in the http section :"
		ewarn ""
		ewarn "  include /etc/nginx/sites.d/*.conf;"
		ewarn ""
	fi


	elog ""
	elog "Configuring"
	elog "You'll have to add a public key associated with a"
	elog "username like this:"
	elog ""
	elog "  cat ~/.ssh/id_rsa.pub | ssh $(hostname -f) \\"
	elog "	 \"sudo sshcommand acl-add ${PN} johndoe\""
	elog ""
}
