#!/bin/bash

TINYOS_TOOLS_VER=1.2.4
TINYOS_TOOLS=tinyos-tools-${TINYOS_TOOLS_VER}

if [[ "$1" == deb ]]
then
    ARCH_TYPE=$(dpkg-architecture -qDEB_HOST_ARCH)
    PREFIX=$(pwd)/${TINYOS_TOOLS}/debian/usr
    PACKAGES_DIR=$(pwd)/../packages/${ARCH_TYPE}
    mkdir -p ${PACKAGES_DIR}
fi

if [[ "$1" == rpm ]]
then
    PREFIX=$(pwd)/${TINYOS_TOOLS}/fedora/usr
fi

: ${PREFIX:=$(pwd)/../local}

LIBTOOLIZE=$(which libtoolize || which glibtoolize)

build()
{
    set -e
    (
	aclocal
	${LIBTOOLIZE} --automake --force --copy
	automake --foreign --add-missing --copy
	autoconf
    	./configure --prefix=${PREFIX}
    	make
	make install
    )
}

package_deb()
{
    echo Packaging ${TINYOS_TOOLS}
    cd ${TINYOS_TOOLS}
    find debian/usr/bin/ -type f \
	| xargs perl -i -pe 's#'${PREFIX}'#/usr#'
    mkdir -p debian/DEBIAN
    cat ../tinyos-tools.control \
	| sed 's/@version@/'${TINYOS_TOOLS_VER}-`date +%Y%m%d`'/' \
        | sed 's/@architecture@/'${ARCH_TYPE}'/' \
        > debian/DEBIAN/control
    dpkg-deb --build debian ${PACKAGES_DIR}/tinyos-tools-${TINYOS_TOOLS_VER}.deb
}

package_rpm()
{
    echo Packaging ${TINYOS_TOOLS}
    find fedora/usr/bin/ -type f \
	| xargs perl -i -pe 's#'${PREFIX}'#/usr#'
    rpmbuild \
	-D "version ${TINYOS_TOOLS_VER}" \
	-D "release `date +%Y%m%d`" \
	-D "prefix ${PREFIX}" \
	-bb tinyos-tools.spec
}

case $1 in
    build)
	build
	;;

    clean)
	git clean -d -f -x
	;;

    deb)
	build
	package_deb
	;;

    rpm)
	build
	package_rpm
	;;

    *)
	build
	;;
esac
