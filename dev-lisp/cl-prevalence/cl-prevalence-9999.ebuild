# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit common-lisp-3 mercurial

DESCRIPTION="CL-PREVALENCE is an implementation of Object Prevalence for Common Lisp."
HOMEPAGE="http://www.common-lisp.net/project/cl-prevalence/"
EHG_REPO_URI="http://bitbucket.org/skypher/${PN}"

LICENSE="LLGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE=""

RDEPEND="dev-lisp/fiveam
		dev-lisp/s-xml
		dev-lisp/s-sysdeps"
