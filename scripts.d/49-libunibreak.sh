
#!/bin/bash

SCRIPT_REPO="https://github.com/adah1972/libunibreak.git"
SCRIPT_COMMIT="3a7a9b99e75fb094f243d4b086b414556a0d9947"

ffbuild_enabled() {
    [[ $TARGET != linux* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    autoreconf -i

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disabled-shared
        --enable-static
        --with-pic
    )

    if [[ $TARGET == linuxarm64 ]]; then
        myconf+=(
            --disable-malloc0returnsnull
        )
    fi

    if [[ $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    export CFLAGS="$RAW_CFLAGS"
    export LDFLAGS="$RAW_LDFLAGS"

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install

    gen-implib "$FFBUILD_PREFIX"/lib/{libunibreak.so.6,libunibreak.a}
    rm "$FFBUILD_PREFIX"/lib/libunibreak{.so*,.la}
}
