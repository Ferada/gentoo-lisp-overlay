# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit common-lisp-2

MY_P=${PN}_${PV:0:3}

DESCRIPTION="CLOS extension for context-oriented Programming"
HOMEPAGE="http://common-lisp.net/project/closer/"
SRC_URI="http://common-lisp.net/project/closer/ftp/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE=""

RDEPEND="!dev-lisp/cl-${PN}
		dev-lisp/lw-compat
		>=dev-lisp/closer-mop-0.60"

S="${WORKDIR}"/${MY_P}

src_install() {
	common-lisp-install *.{lisp,asd} test/*.lisp
	common-lisp-symlink-asdf
}