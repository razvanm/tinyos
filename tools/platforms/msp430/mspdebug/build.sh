#!/bin/bash

MSPDEBUG_VER=0.18
MSPDEBUG=mspdebug-${MSPDEBUG_VER}

if [[ "$1" == deb ]]
then
    ARCH_TYPE=$(dpkg-architecture -qDEB_HOST_ARCH)
    PREFIX=$(pwd)/debian/usr
    PACKAGES_DIR=$(pwd)/../../../../packages/${ARCH_TYPE}
    mkdir -p ${PACKAGES_DIR}
fi

if [[ "$1" == rpm ]]
then
    PREFIX=$(pwd)/${NESC}/fedora/usr
fi

: ${PREFIX:=$(pwd)/../../../../local}

download()
{
    [[ -a ${MSPDEBUG}.tar.gz ]] \
	|| wget http://sourceforge.net/projects/mspdebug/files/${MSPDEBUG}.tar.gz
}

build_mspdebug()
{
    echo Unpacking ${MSPDEBUG}.tar.gz
    rm -rf ${MSPDEBUG}
    tar xzf ${MSPDEBUG}.tar.gz
    set -e
    (
	cd ${MSPDEBUG}
	make -j4
	make install PREFIX=${PREFIX}
    )
}

package_mspdebug()
{
    set -e
    (
	VER=${MSPDEBUG_VER}
	mkdir -p debian/DEBIAN
	cat mspdebug.control \
	    | sed 's/@version@/'${VER}-$(date +%Y%m%d)'/' \
	    | sed 's/@architecture@/'${ARCH_TYPE}'/' \
	    > debian/DEBIAN/control
	dpkg-deb --build debian \
	    ${PACKAGES_DIR}/mspdebug-${VER}.deb
    )
}

package_mspdebug_rpm()
{
    echo Packaging ${MSPDEBUG}
    rpmbuild \
	-D "version ${MSPDEBUG_VER}" \
	-D "release `date +%Y%m%d`" \
	-D "prefix ${PREFIX}/.." \
	-bb mspdebug.spec
}

remove()
{
    for f in $@
    do
	if [ -a ${f} ]
	then
	    echo Removing ${f}
	    rm -rf $f
	fi
    done
}

case $1 in
    download)
	download
	;;

    clean)
	remove ${MSPDEBUG} debian fedora
	;;

    veryclean)
	remove mspdebug-* debian fedora
	;;

    deb)
	download
	build_mspdebug
	package_mspdebug_deb
	;;

    rpm)
	download
	build_mspdebug
	package_mspdebug_rpm
	;;

    *)
	download
	build_mspdebug
	;;
esac
