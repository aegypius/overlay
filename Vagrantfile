# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "cmiles/gentoo-amd64-minimal"
  config.vm.provision "shell", inline: <<-SHELL
    sudo sed -i 's@PORTDIR_OVERLAY=".*"@PORTDIR_OVERLAY="/vagrant /usr/local/portage"@' /etc/portage/make.conf
    sudo sed -i 's@PYTHON_TARGET=".*"@PYTHON_TARGET="python2_7 python3_4"@' /etc/portage/make.conf
    sudo sed -i 's@USE_PYTHON=".*"@USE_PYTHON="3.4 2.7"@' /etc/portage/make.conf
    sudo euse -E -g gnome
    sudo emerge --sync
    sudo echo "dev-vcs/git curl -perl -webdav -gpg" > /etc/portage/package.use/git
    sudo echo "*/*::aegypius ~amd64" > /etc/portage/package.keywords
    sudo echo "
x11-libs/cairo X
sys-devel/llvm clang
app-text/ghostscript-gpl cups
x11-libs/gtk+ X
sys-libs/ncurses tinfo
app-crypt/gcr gtk
    " > /etc/portage/package.use/atom
  SHELL
end
