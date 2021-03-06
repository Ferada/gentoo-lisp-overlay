# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit common-lisp-3 glo-utils eutils elisp-common autotools

DESCRIPTION="Stumpwm is a tiling, keyboard driven X11 Window Manager written entirely in Common Lisp."
HOMEPAGE="http://www.nongnu.org/stumpwm/"
SRC_URI="http://github.com/${PN}/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE="doc clisp ecl +sbcl emacs"

RESTRICT="strip mirror"

RDEPEND="dev-lisp/cl-ppcre
		sbcl? ( >=dev-lisp/clx-0.7.3_p20081030 )
		!sbcl? ( !clisp? ( !ecl? ( >=dev-lisp/sbcl-1.0.32 ) ) )
		!sbcl? ( !clisp? (  ecl? ( >=dev-lisp/ecls-10.4.1 ) ) )
		!sbcl? (  clisp? ( >=dev-lisp/clisp-2.44[X,new-clx] ) )
		sbcl?  ( >=dev-lisp/sbcl-1.0.32 )
		emacs? ( virtual/emacs app-emacs/slime )"
DEPEND="${RDEPEND}
		sys-apps/texinfo
		doc? ( virtual/texi2dvi )"

SITEFILE=70${PN}-gentoo.el

do_doc() {
	local pdffile="${PN}.pdf"

	texi2pdf -o "${pdffile}" "${PN}.texi.in" && dodoc "${pdffile}" || die
	cp "${FILESDIR}"/README.Gentoo . && sed -i "s:@VERSION@:${PV}:" README.Gentoo
	dodoc AUTHORS NEWS README.md README.Gentoo
	doinfo ${PN}.info
	docinto examples ; dodoc sample-stumpwmrc.lisp
}

src_prepare() {
	# Upstream didn't change the version before packaging
	sed -i "${S}/${PN}.asd" -e 's/:version "0.9.8"/:version "0.9.9"/' || die
	eautoreconf
	econf --with-lisp=$(glo_best_flag sbcl clisp ecl)
}

src_compile() {
	emake -j1
}

src_install() {
	common-lisp-export-impl-args $(glo_best_flag sbcl clisp ecl)
	dobin stumpwm
	make_session_desktop StumpWM /usr/bin/stumpwm

	common-lisp-install-sources *.lisp
	common-lisp-install-asdf ${PN}.asd
	use doc && do_doc
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
