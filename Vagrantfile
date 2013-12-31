# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

$script = <<SCRIPT
	export EMERGE_DEFAULT_OPTS="$EMERGE_DEFAULT_OPTS --quiet --color=n"

	echo " --> Adding /vagrant to PORTDIR_OVERLAY"
	sed -i '/^PORTDIR_OVERLAY=/d' /etc/portage/make.conf
	echo PORTDIR_OVERLAY=\"/vagrant\" >> /etc/portage/make.conf

	echo " --> Regenerating overlay metadata"
	emerge --regen || true
SCRIPT


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "gentoo-basebox"
  config.vm.box_url = "http://hq.aegypius.com/public/gentoo-20131230-i686.box"
	config.vm.provision "shell", inline: $script
end
