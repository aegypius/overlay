# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

USE_RUBY="ruby19 ruby20 ruby21 jruby"

RUBY_FAKEGEM_RECIPE_TEST="rspec"
RUBY_FAKEGEM_TASK_DOC=""
RUBY_FAKEGEM_EXTRADOC="CHANGELOG.md README.md"
RUBY_FAKEGEM_GEMSPEC="${PN}.gemspec"

inherit ruby-fakegem

DESCRIPTION="Listens to file modifications and notifies you about the changes."
HOMEPAGE="https://github.com/guard/listen"
SRC_URI="https://github.com/guard/listen/archive/v${PV}.tar.gz -> ${P}-git.tgz"

LICENSE="MIT"
SLOT="2"
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~x86 ~x64-macos"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

ruby_add_rdepend "
  >=dev-ruby/celluloid-0.15.2
  >=dev-ruby/rb-inotify-0.9.0
"

ruby_add_bdepend "
  dev-ruby/rake
  dev-ruby/rspec
  dev-ruby/celluloid-io
  test? ( dev-ruby/mocha virtual/ruby-minitest )
"

all_ruby_prepare() {
	sed -i -e '/[Cc]overalls/d' spec/spec_helper.rb || die
	# Drop failing test
	# sed -i -e '/#85/,+17d' spec/lib/listen/directory_record_spec.rb || die

	# Drop dependencies for file system events not available on Gentoo.
	sed -i -e '/\(fsevent\|kqueue\)/d' ${RUBY_FAKEGEM_GEMSPEC} || die

  epatch ${FILESDIR}/${P}-avoid-using-git-to-list-files.patch
}
