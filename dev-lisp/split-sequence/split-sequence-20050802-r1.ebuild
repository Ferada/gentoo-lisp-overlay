# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit common-lisp-2 eutils

DEB_PV=1

DESCRIPTION="Functions to partition a Common Lisp sequence into multiple result sequences"
HOMEPAGE="http://www.cliki.net/SPLIT-SEQUENCE http://packages.debian.org/sid/cl-${PN}"
SRC_URI="http://ftp.debian.org/debian/pool/main/c/cl-${PN}/cl-${PN}_${PV}.orig.tar.gz
		http://ftp.debian.org/debian/pool/main/c/cl-${PN}/cl-${PN}_${PV}-${DEB_PV}.diff.gz"
LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE=""
DEPEND="!dev-lisp/cl-${PN}"

S="${WORKDIR}/cl-${P}.orig"

src_unpack() {
	unpack ${A}
	epatch cl-${PN}_${PV}-${DEB_PV}.diff
}

src_install() {
	common-lisp-install ${PN}.{asd,lisp}
	common-lisp-system-symlink
	do-debian-credits
}