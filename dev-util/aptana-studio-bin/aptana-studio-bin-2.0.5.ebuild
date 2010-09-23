# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="The world's leading IDE for building open web applications"
HOMEPAGE="http://www.aptana.com"
SRC_URI="http://download.aptana.org/tools/studio/standalone/linux/Aptana_Studio_Setup_Linux_x86_${PV}.zip"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND=">=virtual/jre-1.5
   || ( >=net-libs/xulrunner-1.8 net-libs/xulrunner:1.8 )"

src_install() {
   einfo "Installing Aptana ${PV}"
   dodir "/opt/${PN}"
   local dest="${D}/opt/${PN}"
   cd "${WORKDIR}/Aptana Studio 2.0/"
   cp -pPR about_files/ configuration/ features/ plugins/ "${dest}" || die "Failed to install Files"
   strip -s libcairo-swt.so
   insinto "/opt/${PN}"
   doins libcairo-swt.so about.html AptanaStudio.ini full_uninstall.txt version.txt
   exeinto "/opt/${PN}"
   doexe AptanaStudio

   dodir /opt/bin
   echo "#!/bin/sh" > ${T}/AptanaStudio
   if [ -x /opt/xulrunner ]; then
      echo "export MOZILLA_FIVE_HOME=/opt/xulrunner" >> ${T}/AptanaStudio
   else
      echo "export MOZILLA_FIVE_HOME=/usr/lib/xulrunner" >> ${T}/AptanaStudio
   fi
   echo "/opt/${PN}/AptanaStudio" >> ${T}/AptanaStudio
   dobin ${T}/AptanaStudio

   newicon plugins/com.aptana.ide.branding_2.0.0.1278523018/aptana32.gif AptanaStudio.png
   make_desktop_entry "AptanaStudio" "Aptana Studio" AptanaStudio "Development"
}
