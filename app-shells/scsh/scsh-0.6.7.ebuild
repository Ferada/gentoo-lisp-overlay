# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/scsh/scsh-0.6.7.ebuild,v 1.6 2008/08/03 16:10:31 pchrist Exp $

EAPI="2"

inherit eutils multilib 

MY_PV="${PV%*.*}"

DESCRIPTION="Unix shell embedded in Scheme"
HOMEPAGE="http://www.scsh.net/"
SRC_URI="ftp://ftp.scsh.net/pub/scsh/${MY_PV}/${P}.tar.gz"
LICENSE="as-is BSD"
SLOT="0"
KEYWORDS="~amd64 ppc sparc x86"
IUSE=""

DEPEND="!dev-scheme/scheme48"
RDEPEND="${DEPEND}"


src_prepare() {
	epatch "${FILESDIR}/${PV}-Makefile.in-doc-dir-gentoo.patch"
}

src_configure() {
	use amd64 && multilib_toolchain_setup x86
	SCSH_LIB_DIRS="/usr/$(get_libdir)/scsh"
	econf \
		--libdir=/usr/$(get_libdir) \
		--includedir=/usr/include \
		--with-lib-dirs-list=${SCSH_LIB_DIRS}
}

src_install() {
	local ENVD="${T}/50scsh"
	emake -j1 DESTDIR="${D}" install || die "make install failed."
	echo "SCSH_LIB_DIRS=\"${SCSH_LIB_DIRS}\"" > ${ENVD}
	doenvd "${ENVD}"
}
