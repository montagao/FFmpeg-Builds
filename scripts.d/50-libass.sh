#!/bin/bash

SCRIPT_REPO="https://github.com/libass/libass.git"
SCRIPT_COMMIT="c5bb87e2f5d6c18763b4614817c206a4f4d2332a"

LIBUNIBREAK_REPO="https://github.com/adah1972/libunibreak.git"
LIBUNIBREAK_COMMIT="ab77349"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    # Build libunibreak
    git clone "$LIBUNIBREAK_REPO" libunibreak
    cd libunibreak
    git checkout "$LIBUNIBREAK_COMMIT"
    ./autogen.sh --prefix="$FFBUILD_PREFIX"
    make -j$(nproc)
    make install
    cd ..

    # Build libass
    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
        --enable-libunibreak  # Enable libunibreak support
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    export CFLAGS="$CFLAGS -Dread_file=libass_internal_read_file"
    export LDFLAGS="$LDFLAGS -L$FFBUILD_PREFIX/lib"  # Add libunibreak to library search path

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libass
}

ffbuild_unconfigure() {
    echo --disable-libass
}
