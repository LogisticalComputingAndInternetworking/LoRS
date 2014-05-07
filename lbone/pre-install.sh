#!/bin/sh

# build and install ibp package
BUILD_IBP=yes
if test "${BUILD_IBP}" = yes; then
    echo "Building ibp package..."
    cd /Users/brumgard/Documents/Work/LoCI/workspace/lors/lbone/ibp
    ./configure --prefix=/sw/lors/ --enable-clientonly=yes
    make install
    if test $? -ne 0; then
        echo "****** Error in building ibp package"
        cd /Users/brumgard/Documents/Work/LoCI/workspace/lors/lbone
        /bin/rm Makefile
        exit 1
    fi
    cd /Users/brumgard/Documents/Work/LoCI/workspace/lors/lbone
fi

BUILD_ECGI=no,
if test "${BUILD_ECGI}" = yes; then
    echo "Building ecgi package..."
    cd 
    make
    ranlib libecgi.a
    if test $? -ne 0; then
        echo "****** Error in building ecgi package"
        cd /Users/brumgard/Documents/Work/LoCI/workspace/lors/lbone
        /bin/rm Makefile
        exit 1
    fi
    cd /Users/brumgard/Documents/Work/LoCI/workspace/lors/lbone
fi

BUILD_NWS=no,
if test "${BUILD_NWS}" = yes; then
    echo "Building nws package..."
    cd 
    make clean
    rm -f config.status config.cache
    ./configure && make lib
    cd Sensor/ExpMemory
    make memory.o
    ar -q ../../libnws.a memory.o
    cd ../../ 
    ranlib ./libnws.a
    mkdir -p Library/$UNAME/
    cp libnws.a Library/$UNAME/
    if test $? -ne 0; then
        echo "****** Error in building nws package"
        cd /Users/brumgard/Documents/Work/LoCI/workspace/lors/lbone
        /bin/rm Makefile
        exit 1
    fi
    cd /Users/brumgard/Documents/Work/LoCI/workspace/lors/lbone
fi

exit 0

