# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit flag-o-matic eutils toolchain-funcs multilib

DESCRIPTION="A portable, bytecode-compiled implementation of Common Lisp"
HOMEPAGE="http://clisp.sourceforge.net/"
SRC_URI="mirror://sourceforge/clisp/${P}.tar.bz2"
LICENSE="GPL-2"

# EAPI="1"
SLOT="2"
KEYWORDS="~amd64 ~ppc ~ppc64 -sparc ~x86"
IUSE="hyperspec X new-clx fastcgi gdbm gtk pari pcre postgres readline svm zlib"

RDEPEND="virtual/libiconv
		 >=dev-libs/libsigsegv-2.4
		 >=dev-libs/ffcall-1.10
		 fastcgi? ( dev-libs/fcgi )
		 gdbm? ( sys-libs/gdbm )
		 gtk? ( >=x11-libs/gtk+-2.10 >=gnome-base/libglade-2.6 )
		 pari? ( >=sci-mathematics/pari-2.3.0 )
		 postgres? ( >=dev-db/postgresql-8.0 )
		 readline? ( sys-libs/readline )
		 pcre? ( dev-libs/libpcre )
		 svm? ( sci-libs/libsvm )
		 zlib? ( sys-libs/zlib )
		 X? ( new-clx? ( x11-libs/libXpm ) )
		 hyperspec? ( dev-lisp/hyperspec )"
# 		 berkdb? ( sys-libs/db:4.5 )

DEPEND="${RDEPEND} X? ( new-clx? ( x11-misc/imake x11-proto/xextproto ) )"

PDEPEND="dev-lisp/gentoo-init"

PROVIDE="virtual/commonlisp"

enable_modules() {
	[[ $# = 0 ]] && die "${FUNCNAME[0]} must receive at least one argument"
	for m in "$@" ; do
		einfo "enabling module $m"
		myconf="${myconf} --with-module=${m}"
	done
}

BUILDDIR="builddir"

# modules not enabled:
#  * berkdb: must figure out a way to make the configure script pick up the
#            currect version of the library and headers
#  * dirkey: fails to compile, requiring windows.h, possibly wrong #ifdefs
#  * matlab, netica: not in portage
#  * oracle: can't install oracle-instantclient

src_compile() {
	# built-in features
	local myconf="--with-ffcall --with-dynamic-modules"
	use readline || myconf="${myconf} --with-noreadline"

	# default modules
	enable_modules wildcard rawsock i18n
	# optional modules
	use elibc_glibc && enable_modules bindings/glibc
	if use X; then
		if use new-clx; then
			enable_modules clx/new-clx
		else
			enable_modules clx/mit-clx
		fi
	fi
	if use postgres; then
		enable_modules postgresql
		CPPFLAGS="-I $(pg_config --includedir)"
	fi
# 	if use berkdb; then
# 		enable_modules berkley-db
# 		CPPFLAGS="${CPPFLAGS} -I /usr/include/db4.5"
# 	fi
	use fastcgi && enable_modules fastcgi
	use gdbm && enable_modules gdbm
	use gtk && enable_modules gtk2
	use pari && enable_modules pari
	use pcre && enable_modules pcre
	use svm && enable_modules libsvm
	use zlib && enable_modules zlib

	if use hyperspec; then
		CLHSROOT="file:///usr/share/doc/hyperspec/HyperSpec/"
	else
		CLHSROOT="http://www.lispworks.com/reference/HyperSpec/"
	fi

	# configure chokes on --infodir option
	./configure --prefix=/usr --libdir=/usr/$(get_libdir) \
		${myconf} --hyperspec=${CLHSROOT} ${BUILDDIR} || die "./configure failed"
	cd ${BUILDDIR}
	sed -i 's,"vi","nano",g' config.lisp
	IMPNOTES="file://${ROOT%/}/usr/share/doc/${PN}-${PVR}/html/impnotes.html"
	sed -i "s,http://clisp.cons.org/impnotes/,${IMPNOTES},g" config.lisp
	# parallel build fails
	emake -j1 || die "emake failed"
}

src_install() {
	pushd ${BUILDDIR}
	make DESTDIR="${D}" prefix=/usr install-bin || die
	doman clisp.1
	dodoc SUMMARY README* NEWS MAGIC.add ANNOUNCE clisp.dvi clisp.html
	chmod a+x "${D}"/usr/$(get_libdir)/clisp-${PV/_*/}/clisp-link
	# stripping them removes common symbols (defined but unitialised variables)
	# which are then needed to build modules...
	export STRIP_MASK="*/usr/$(get_libdir)/clisp-${PV}/*/*"
	popd
	dohtml doc/impnotes.{css,html} ${BUILDDIR}/clisp.html doc/clisp.png
	dodoc ${BUILDDIR}/clisp.ps doc/{editors,CLOS-guide,LISP-tutorial}.txt
}