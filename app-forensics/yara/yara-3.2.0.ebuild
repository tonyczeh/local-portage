# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python{2_7,3_2,3_3,3_4} )

inherit autotools distutils-r1 eutils

DESCRIPTION="The pattern matching swiss knife for malware researchers
	(and everyone else)."
HOMEPAGE="https://plusvic.github.io/yara/"
SRC_URI="https://github.com/plusvic/yara/archive/v${PV}.tar.gz -> yara-${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT=0
KEYWORDS="~amd64 ~x86"
IUSE="cuckoo +openssl magic python"

RDEPEND="
	cuckoo? ( dev-libs/jansson )
	magic? ( sys-apps/file )
	python? ( ${PYTHON_DEPS} )"

DEPEND="
	${RDEPEND}
	>=sys-devel/automake-1.7"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

src_prepare() {
	eautoreconf
}

src_configure() {
	local myconf=

	# Make sure we don't build against OpenSSL without the proper USE flag.
	if use openssl ; then
		myconf+=" --with-crypto"
	else
		myconf+=" --without-crypto"
	fi

	econf \
		$(use_enable cuckoo) \
		$(use_enable magic) \
		${myconf}
}

python_compile() {
	distutils-r1_python_compile build_ext -I ../ -L ../${PN}
}

src_compile() {
	default

	if use python ; then
		pushd "${S}/yara-python" > /dev/null
		distutils-r1_src_compile
		popd > /dev/null
	fi
}

src_install() {
	emake DESTDIR="${D}" install

	if use python ; then
        pushd "${S}/yara-python" > /dev/null
        # Unset DOCS. This has been handled by the default target
        unset DOCS
        distutils-r1_src_install
        popd > /dev/null
	fi
}
