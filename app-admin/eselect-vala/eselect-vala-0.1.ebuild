EAPI="3"

DESCRIPTION="Eselect module to maintain vala compiler symlink"
HOMEPAGE="http://github.com/ulltor/eselect-vala"

SRC_URI="https://github.com/downloads/ulltor/${PN}/${PN}-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-lang/vala
	app-admin/eselect"
RDEPEND="${DEPEND}"

DOCS="AUTHORS COPYING"

src_install() {
	insinto /usr/share/eselect/modules/
    doins vala.eselect || die
    
    dodoc ${DOCS}
}
