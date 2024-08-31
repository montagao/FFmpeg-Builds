#!/bin/bash

SCRIPT_REPO="https://github.com/libass/libass.git"
SCRIPT_COMMIT="c5bb87e2f5d6c18763b4614817c206a4f4d2332a"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
dd    # Build libass
    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
        --enable-libunibreak
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

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install

    # Add libunibreak to the Requires.private field in libass.pc
    echo "Requires.private: libunibreak" >> "$FFBUILD_PREFIX/lib/pkgconfig/libass.pc"

}

ffbuild_configure() {
    echo --enable-libass
}

ffbuild_unconfigure() {
    echo --disable-libass
}
