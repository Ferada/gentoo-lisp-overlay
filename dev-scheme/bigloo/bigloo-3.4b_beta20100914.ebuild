# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit elisp-common multilib eutils flag-o-matic java-pkg-opt-2

MY_P=${PN}${PV/_p/-}
MY_P=${MY_P/_alpha*/-alpha}
MY_P=${MY_P/_beta*/-beta}

BGL_RELEASE=${PV/_*/}

DESCRIPTION="Bigloo is a Scheme implementation."
HOMEPAGE="http://www-sop.inria.fr/indes/fp/Bigloo/bigloo.html"
SRC_URI="ftp://ftp-sop.inria.fr/indes/fp/Bigloo/${MY_P}14Sep10.tar.gz
		 ftp://ftp-sop.inria.fr/members/Cyprien.Nicolas/mirror/${MY_P}14Sep10.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="calendar crypto debug doc emacs gstreamer java mail multimedia openpgp packrat sqlite srfi1 srfi27 ssl text threads web"

# bug 254916 for >=dev-libs/boehm-gc-7.1
DEPEND_COMMON=">=dev-libs/boehm-gc-7.1[threads?]
	emacs? ( virtual/emacs )
	sqlite? ( dev-db/sqlite:3 )
	ssl? ( dev-libs/openssl )
	gstreamer? ( media-libs/gstreamer media-libs/gst-plugins-base )"

DEPEND="${DEPEND_COMMON}  java? ( >=virtual/jdk-1.5 app-arch/zip )"
RDEPEND="${DEPEND_COMMON} java? ( >=virtual/jre-1.5 )"

S=${WORKDIR}/${MY_P/-[ab]*/}

SITEFILE="50bigloo-gentoo.el"

pkg_setup() {
	if use gstreamer; then
		if ! use threads; then
			die "USE Dependency: 'gstreamer' needs 'threads'. You may enable 'threads', or disable 'gstreamer'."
		fi

		if ! use multimedia; then
			die "USE Dependency: 'gstreamer' needs 'multimedia'."
		fi
	fi

	if use packrat && ! use srfi1; then
		die "USE Dependency: 'packrat' needs 'srfi1'."
	fi

	if ! use x86 && use srfi27; then
		ewarn "srfi27 is known to only work on x86 architectures. It is higly suggested that you disable it." \
			" It is not supported by upstream, and tests *will* fail. You've been warned."
	fi

	if ! use crypto && use openpgp; then
		die "USE Dependency: 'openpgp' needs 'crypto'."
	fi
}

src_prepare() {
	# Force libbigloosqlite to be build if sqltiny is used
	epatch "${FILESDIR}/${PN}-${BGL_RELEASE}-sqltiny_support.patch"

	# bglmem is not built according to the EFLAGS
	#  (which forces LDFLAGS, see emake below)
	ebegin "Adding EFLAGS to BMEMFLAGS"
	sed -i 's/BMEMFLAGS[^=]\+= /&$(EFLAGS) /' bde/bmem/Makefile
	eend $?

	# Removing bundled boehm-gc
	rm -rf gc || die
}

src_configure() {
	filter-flags -fomit-frame-pointer

	local myconf=""

	# Filter Zile emacs replacement. Bug #336717
	if use emacs; then
		myconf="--emacs=emacs --bee=full"
	else
		myconf="--emacs=false --bee-=partial"
	fi

	# Sqlite backend
	myconf="${myconf} --sqlite-backend=$(if use sqlite; then echo sqlite; else echo sqltiny; fi)"

	# Need fix for bglpkg, which depends on pkglib, pkgcomp, sqlite and web.
	# This cannot be disabled for now, working on a fix.
	myconf="${myconf} --enable-pkgcomp --enable-pkglib --enable-web"

	# Bigloo doesn't use autoconf and consequently a lot of options used by econf give errors
	# Manuel Serrano says: "Please, dont talk to me about autoconf. I simply dont want to hear about it..."
	./configure \
		$(use java && echo "--jvm=yes --java=$(java-config --java) --javac=$(java-config --javac)") \
		--prefix="${EPREFIX}/usr" \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
		--libdir=/usr/$(get_libdir) \
		--docdir=/usr/share/doc/${PF} \
		--lispdir="${SITELISP}/${PN}" \
		--benchmark=yes \
		--sharedbde=no \
		--sharedcompiler=no \
		--customgc=no \
		--coflags="" \
		--ldflags="${LDFLAGS}" \
		--strip=no \
		$(use debug && echo "--debug") \
		${myconf} \
		$(use_enable calendar) \
		$(use_enable crypto) \
		$(use_enable gstreamer) \
		$(use_enable mail) \
		$(use_enable multimedia) \
		$(use_enable packrat) \
		$(use_enable openpgp) \
		$(use_enable srfi1) \
		$(use_enable srfi27) \
		$(use_enable ssl) \
		$(use_enable text) \
		$(use_enable threads) \
		|| die "configure failed"
}

src_compile() {
	emake EFLAGS='-ldopt "$(LDFLAGS)"' || die "emake failed"

	if use emacs; then
		einfo "Compiling bee..."
		emake compile-bee EFLAGS='-ldopt "$(LDFLAGS)"' || die "compiling bee failed"
	fi
}

# default thinks that target doesn't exist
src_test() {
	emake -j1 test || die "emake test failed"
}

src_install() {
	# Makefile:671:install: install-progs install-docs
	emake DESTDIR="${D}" install-progs || die "install failed"

	if use emacs; then
		einfo "Installing bee..."
		emake DESTDIR="${D}" install-bee || die "install-bee failed"
		elisp-site-file-install "${FILESDIR}/${SITEFILE}"
	fi

	if use doc; then
		dohtml -r manuals/ || die "dohtml failed"
		doinfo manuals/*.info* || die "doinfo failed"
	fi

	for man in manuals/*.man; do
		man1=${man#manuals/}
		newman ${man} ${man1/.man/.1} || die "newman ${man/.man/.1} failed"
	done

	dodoc ChangeLog README || die "dodoc failed"
	newdoc LICENSE COPYING || die "newdoc failed"
}

pkg_postinst() {
	if use emacs; then
		elisp-site-regen
		elog "In order to use the bee-mode, add"
		elog "  (require 'bmacs)"
		elog "to your ~/.emacs file"
	fi
}

pkg_postrm() {
	use emacs && elisp-site-regen
}