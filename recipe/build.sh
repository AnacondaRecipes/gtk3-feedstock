#! /bin/bash
# Prior to conda-forge, Copyright 2014-2019 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -ex

export PKG_CONFIG="$BUILD_PREFIX/bin/pkg-config"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig:${PKG_CONFIG_PATH:-}"
export CMAKE_PREFIX_PATH="$PREFIX:${CMAKE_PREFIX_PATH:-}"

# make sure pkg-config file name matches what meson expects
if [[ -f "$PREFIX/lib/pkgconfig/libepoxy.pc" && ! -f "$PREFIX/lib/pkgconfig/epoxy.pc" ]]; then
  ln -s "$PREFIX/lib/pkgconfig/libepoxy.pc" "$PREFIX/lib/pkgconfig/epoxy.pc"
fi
if [[ -f "$PREFIX/lib64/pkgconfig/libepoxy.pc" && ! -f "$PREFIX/lib64/pkgconfig/epoxy.pc" ]]; then
  ln -s "$PREFIX/lib64/pkgconfig/libepoxy.pc" "$PREFIX/lib64/pkgconfig/epoxy.pc"
fi


echo "=== epoxy pkg-config check ==="
ls -la "$PREFIX/lib/pkgconfig" "$PREFIX/lib64/pkgconfig" | grep -i epoxy || true
$PKG_CONFIG --print-errors --list-all | grep -i epoxy || true
$PKG_CONFIG --print-errors --modversion epoxy || true
echo "=== epoxy pkg-config check END ==="

meson_config_args=(
    -D gtk_doc=false
    -D demos=false
    -D tests=false
    -D examples=false
    -D installed_tests=false
    -D wayland_backend=false
)

# ensure that the post install script is ignored
export DESTDIR="/"

meson setup builddir \
    "${meson_config_args[@]}" \
    --prefix=$PREFIX \
    --libdir=lib \
    --wrap-mode=nofallback

ninja -v -C builddir -j ${CPU_COUNT}
ninja -C builddir install -j ${CPU_COUNT}

cd $PREFIX
find . '(' -name '*.la' -o -name '*.a' ')' -delete
rm -rf $(echo "
share/applications
share/gtk-doc
share/man
bin/gtk3-demo*
bin/gtk3-icon-browser
bin/gtk3-widget-factory
")

