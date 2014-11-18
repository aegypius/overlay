# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Simple web focused Dockerfile based PaaS server"
HOMEPAGE="http://www.octohost.io"

EGIT_REPO_URI="git://github.com/octohost/octohost.git"
if [[ ${PV} == *9999 ]]; then
	KEYWORDS=""
else
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64"
fi

inherit git-2 user systemd

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND="
	${DEPEND}
	www-servers/nginx[nginx_modules_http_spdy,nginx_modules_http_geoip]
	app-emulation/docker
	app-admin/consul
	app-admin/sudo
	app-admin/octoconfig
	app-misc/jq
	dev-vcs/git
	virtual/ssh
"

src_prepare () {
	wget https://raw.githubusercontent.com/octohost/octohost-cookbook/master/files/default/consulkv -O bin/consulkv
	wget https://raw.githubusercontent.com/octohost/octohost-cookbook/master/files/default/location.conf -O config/location.conf
	wget https://raw.githubusercontent.com/octohost/octohost-cookbook/master/files/default/ssl.conf -O config/ssl.conf

	epatch "${FILESDIR}/0001-${PN}-guess-private-ip-address.patch"

	sed -i "s@sudo docker @docker @g" bin/octo \
		|| die "Failed to remove sudo for docker commands in octo"

	sed -i "s@octoconfig update@octoconfig --reload=\"systemctl reload nginx\" update@g" bin/octo \
		|| die "Failed to update octoconfig"

	sed -i "s@sudo docker @docker @g" bin/receiver.sh \
		|| die "Failed to remove sudo for docker commands in receiver"

	sed -i "s@SRC_DIR=\"/home/git/src\"@SRC_DIR=\"/var/lib/${PN}/src\"@g" bin/default \
		|| die "Failed to sed config defaults"

	sed -i "s@/etc/log_files.yml@/etc/octohost/log_files.yml@g" bin/default \
		|| die "Failed to sed config defaults"

	sed -i "s@GITUSER=.*@GITUSER=\${GITUSER:-${PN}}@" bin/gitreceive \
		|| die "Failed to sed gitreceive defaults"

	sed -i "s@GITHOME=.*@GITHOME=\"/usr/lib/\${GITUSER}\"@" bin/gitreceive \
		|| die "Failed to sed gitreceive defaults"
}

pkg_setup() {
	enewgroup "${PN}"
	enewuser  "${PN}" -1 /bin/sh "/usr/lib/${PN}" "${PN} docker"

}

src_install () {

	insinto "/usr/lib/${PN}"
	exeinto "/usr/lib/${PN}"

	newexe bin/receiver.sh receiver

	insinto "/usr/lib/${PN}/.ssh"
	newins "${FILESDIR}/authorized_keys" authorized_keys

	chown -R "${PN}:${PN}" "${D}/usr/lib/${PN}"

	insinto "/etc/default"
	newins bin/default "${PN}"

	insinto "/etc/sysctl.d"
	newins "${FILESDIR}/sysctl.conf" "99-${PN}.conf"

	insinto "/etc/sudoers.d"
	newins "${FILESDIR}/sudoers.conf" "${PN}"

	insinto "/etc/nginx"
	newins config/location.conf location.conf
	newins config/ssl.conf ssl.conf
	newins "${FILESDIR}/proxy.conf" octohost.conf

	insinto "/etc/${PN}"
	newins config/log_files.yml log_files.yml

	exeinto "/usr/bin"
	doexe bin/octo
	doexe bin/gitreceive
	doexe bin/consulkv

	keepdir "/var/lib/${PN}"
	fowners "${PN}:${PN}" "/var/lib/${PN}"
	fperms  750           "/var/lib/${PN}"

}

pkg_postinst() {
	grep -Fxq '#includedir /etc/sudoers.d' /etc/sudoers
	if [[ $? -eq 1 ]]; then
		ewarn ""
		ewarn "${PN} requires to reload services after each"
		ewarn "deployment. Please update your sudoers config with:"
		ewarn ""
		ewarn "  echo '#includedir /etc/sudoers.d' >> /etc/sudoers"
		ewarn ""
	fi

	grep -Fq 'include /etc/nginx/octohost.conf;' /etc/nginx/nginx.conf
	if  [[ $? -eq 1 ]]; then
		ewarn ""
		ewarn "${PN} plugin requires to load virtual host configuration."
		ewarn "Please add the following line to your /etc/nginx/nginx.conf"
		ewarn "in the http section :"
		ewarn ""
		ewarn "  include /etc/nginx/octohost.conf;"
		ewarn ""
	fi

	elog ""
	elog "Configuring"
	elog "You'll have to add a public key associated with a"
	elog "username like this:"
	elog ""
	elog "  cat ~/.ssh/id_rsa.pub | ssh ${PN}@$(hostname -f) \"gitreceive upload-key johndoe\""
	elog ""

}
