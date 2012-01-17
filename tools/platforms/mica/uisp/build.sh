#!/bin/bash

UISP_VER=20050519tinyos
UISP=uisp-${UISP_VER}

if [[ "$1" == deb ]]
then
    ARCH_TYPE=$(dpkg-architecture -qDEB_HOST_ARCH)
    PREFIX=$(pwd)/${UISP}/debian/usr
    PACKAGES_DIR=$(pwd)/../../../../packages/debian/${ARCH_TYPE}
    mkdir -p ${PACKAGES_DIR}
fi

if [[ "$1" == rpm ]]
then
    PREFIX=$(pwd)/${UISP}/fedora/usr
fi

: ${PREFIX:=$(pwd)/../../../../local}

build()
{
    set -e
    (
	./bootstrap
	./configure --prefix=${PREFIX}
	make
	make install-strip
    )
}

package_deb()
{
    echo Packaging ${UISP}
    cd ${UISP}
    find debian/usr/bin/ -type f \
	| xargs perl -i -pe 's#'${PREFIX}'#/usr#'
    mkdir -p debian/DEBIAN
    cat ../uisp.control \
	| sed 's/@version@/'${UISP_VER}-`date +%Y%m%d`'/' \
	| sed 's/@architecture@/'${ARCH_TYPE}'/' \
	> debian/DEBIAN/control
    dpkg-deb --build debian ${PACKAGES_DIR}/uisp-${UISP_VER}.deb
}

package_rpm()
{
    echo Packaging ${UISP}
    find ${UISP}/fedora/usr/bin/ -type f \
	| xargs perl -i -pe 's#'${PREFIX}'#/usr#'
    rpmbuild \
	-D "version ${UISP_VER}" \
	-D "release `date +%Y%m%d`" \
	-D "prefix ${PREFIX}" \
	-bb uisp-tinyos.spec

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
