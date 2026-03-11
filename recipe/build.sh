#! /bin/bash
# Prior to conda-forge, Copyright 2014-2019 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -ex

# GDK backend defaults (from meson_options.txt):
#  - x11_backend     = true   (enabled by default on Unix/Linux)
#  - wayland_backend = true   (enabled by default on Unix except macOS)
#  - broadway_backend= false  (disabled by default)
#  - win32_backend   = true   (enabled by default on Windows only)
#  - quartz_backend  = true   (enabled by default on macOS only)
#
# In practice this means:
#  - Linux builds enable X11 + Wayland by default
#  - macOS builds enable Quartz only
#  - Windows builds enable Win32 only

export PKG_CONFIG="$BUILD_PREFIX/bin/pkg-config"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig:${PKG_CONFIG_PATH:-}"
export CMAKE_PREFIX_PATH="$PREFIX:${CMAKE_PREFIX_PATH:-}"

meson_config_args=(
    -D gtk_doc=false
    -D demos=false
    -D tests=false
    -D examples=false
    -D installed_tests=false
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

