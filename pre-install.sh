#!/bin/sh

# build and install popt package
BUILD_POPT=yes
if test "${BUILD_POPT}" = yes; then
    echo "Building popt package..."
    cd /Users/brumgard/Documents/Work/LoCI/workspace/lors/popt
    ./configure --prefix=/sw/lors 
    make install-libLTLIBRARIES install-includeHEADERS
    if test $? -ne 0; then
        echo "****** Error in building popt package"
        cd /Users/brumgard/Documents/Work/LoCI/workspace/lors
        /bin/rm Makefile
        exit 1
    fi
    cd /Users/brumgard/Documents/Work/LoCI/workspace/lors
fi
BUILD_ZLIB=no
if test "${BUILD_ZLIB}" = yes; then
    echo "Building zlib package..."
    cd 
    ./configure --prefix=/sw/lors
    make install
    if test $? -ne 0; then
        echo "****** Error in building zlib package"
        cd /Users/brumgard/Documents/Work/LoCI/workspace/lors
        /bin/rm Makefile
        exit 1
    fi
    cd /Users/brumgard/Documents/Work/LoCI/workspace/lors
fi
BUILD_XML2=no
if test "${BUILD_XML2}" = yes; then
    echo "Building libxml2 package..."
    cd 
    if test "x/usr" = "x/usr" ; then
        ./configure --prefix=/sw/lors --without-python
    else 
        ./configure --prefix=/sw/lors --with-zlib=/usr --without-python
    fi
    make install
    if test $? -ne 0; then
        echo "****** Error in building libxml2 package"
        cd /Users/brumgard/Documents/Work/LoCI/workspace/lors
        /bin/rm Makefile
        exit 1
    fi
    cd /Users/brumgard/Documents/Work/LoCI/workspace/lors
fi
BUILD_LBONE=no
if test "${BUILD_LBONE}" = yes; then
    echo "Building lbone package..."
    cd 
    ./configure --prefix=/sw/lors 
    make install
    cd /Users/brumgard/Documents/Work/LoCI/workspace/lors 
fi
BUILD_LIBXND=no
if test "${BUILD_LIBXND}" = yes; then
    echo "Building libexnode package..."
    cd 
    ./configure --prefix=/sw/lors --with-libxml2=/usr --with-libfdr=/sw/lors
    make install
    cd /Users/brumgard/Documents/Work/LoCI/workspace/lors
fi

#BUILD_LIBAES=no
#if test "${BUILD_LIBAES}" = yes; then
#    echo "Building libaes package..."
#    cd 
#    ./configure --prefix=/sw/lors
#    make install
#    cd /Users/brumgard/Documents/Work/LoCI/workspace/lors
#fi

exit 0

