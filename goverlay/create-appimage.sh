#!/usr/bin/env bash

# Extract linuxdeploy se we not use fuse for building
/linuxdeploy.AppImage --appimage-extract

# Go to git
cd ./git

# Patch goverlay binary to remove hardcoded path and use vkbasalt AppImage instead of variable
sed -i \
  -e 's#/usr#././#g' \
  ./AppDir/usr/bin/goverlay

# Copy MangoHud and vkBasalt libs
git clone https://github.com/kadogo/easy-builder.git

# Install libs to right directories
mkdir -p ./AppDir/usr/share/vulkan/implicit_layer.d/
mkdir -p ./AppDir/usr/lib/mangohud/
mkdir -p ./AppDir/usr/lib32/mangohud/
# MangoHud
cp -a ./easy-builder/release/mangohud/vulkan/implicit_layer.d/* ./AppDir/usr/share/vulkan/implicit_layer.d/
cp -a ./easy-builder/release/mangohud/lib/ ./AppDir/usr/lib/mangohud/
cp -a ./easy-builder/release/mangohud/lib32/ ./AppDir/usr/lib/mangohud/
# vkBasalt
cp -a ./easy-builder/release/vkBasalt/vulkan/implicit_layer.d/* ./AppDir/usr/share/vulkan/implicit_layer.d/
cp -a ./easy-builder/release/vkBasalt/lib* ./AppDir/usr/lib/
cp -a ./easy-builder/release/vkBasalt/i386-linux-gnu/ ./AppDir/usr/lib/

# Bundle GTK2 (https://docs.appimage.org/packaging-guide/manual.html#bundling-gtk-libraries
wget https://raw.githubusercontent.com/aferrero2707/appimage-helper-scripts/master/bundle-gtk2.sh
chmod +x bundle-gtk2.sh
APPDIR="$(pwd)/AppDir/" ./bundle-gtk2.sh

# Create mangohud wrapper
# Based on mangohud appimage AppRun
cat <<'EOF' > ./AppDir/usr/bin/mangohud
#!/bin/bash

HERE="$(dirname "$(readlink -f "${0}")")"

if [ "$#" -eq 0 ]; then
        programname=`basename "$0"`
        echo "ERROR: No program supplied"
        echo
        echo "Usage: $programname <program>"
        exit 1
fi

if [ "$1" = "--dlsym" ]; then
        MANGOHUD_DLSYM=1
        shift
fi

MANGOHUD_LIB_NAME="libMangoHud.so"

if [ "$MANGOHUD_DLSYM" = "1" ]; then
        MANGOHUD_LIB_NAME="libMangoHud_dlsym.so:${MANGOHUD_LIB_NAME}"
fi

# Preload using the plain filesnames of the libs, the dynamic linker will
# figure out whether the 32 or 64 bit version should be used, and will search
# for it in the correct directory
LD_PRELOAD="${LD_PRELOAD}:${MANGOHUD_LIB_NAME}"
LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$HERE/usr/lib/mangohud/\$LIB/"

exec env MANGOHUD=1 LD_LIBRARY_PATH="${LD_LIBRARY_PATH}" LD_PRELOAD="${LD_PRELOAD}" "$@"
EOF

# Set mangohud wrapper executable
chmod +x ./AppDir/usr/bin/mangohud

# Create wrapper
# Carefull to escape $ and backslash properly
# https://github.com/probonopd/linuxdeployqt/wiki/Custom-wrapper-script-instead-of-AppRun
cat <<'EOF' > ./AppDir/AppRun
#!/bin/bash

HERE="$(dirname "$(readlink -f "${0}")")"

export GDK_PIXBUF_MODULEDIR="${HERE}/usr/lib/gdk-pixbuf-2.0/loaders"
export GDK_PIXBUF_MODULE_FILE="${HERE}/usr/lib/gdk-pixbuf-2.0/loaders.cache"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$GDK_PIXBUF_MODULEDIR:${HERE}/usr/lib/"
export GTK_PATH="$HERE/usr/lib/gtk-2.0"
export GTK_IM_MODULE_FILE="$HERE/usr/lib/gtk-2.0:$GTK_PATH"
export PANGO_LIBDIR="$HERE/usr/lib"

# Add bin path from AppImage in PATH
export PATH="$PATH:${HERE}/usr/bin/"

# Add Vulkan layer path and activate mangohud and vkbasalt
export VK_LAYER_PATH="${VK_LAYER_PATH}:$HERE/usr/share/vulkan/implicit_layer.d/"
export VK_INSTANCE_LAYERS=${VK_INSTANCE_LAYERS}:VK_LAYER_MANGOHUD_overlay:VK_LAYER_VKBASALT_post_processing

# Add Mangohud lib because it looks like it's not working properly from the wrapper
export LD_PRELOAD="${LD_PRELOAD}:libMangoHud.so"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$HERE/usr/lib/mangohud/\$LIB/"

cd ${HERE}/usr

# Debug
echo "GDK_PIXBUF_MODULEDIR: $GDK_PIXBUF_MODULEDIR"
echo "GDK_PIXBUF_MODULE_FILE: $GDK_PIXBUF_MODULE_FILE"
echo "LD_PRELOAD: $LD_PRELOAD"
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo "GTK_PATH: $GTK_PATH"
echo "GTK_IM_MODULE_FILE: $GTK_IM_MODULE_FILE"
echo "PANGO_LIBDIR: $PANGO_LIBDIR"
echo "PATH: $PATH"
echo "VK_LAYER_PATH: $VK_LAYER_PATH"
echo "VK_INSTANCE_LAYERS: $VK_INSTANCE_LAYERS"

exec ./bin/goverlay
EOF

# Set execute bit
chmod +x ./AppDir/AppRun

# Create symlink in AppDir like the mangohud-setup script
cd ./AppDir/usr/
# FIXME get the triplet somehow
ln -sv lib ././lib/mangohud/lib64
ln -sv lib ././lib/mangohud/x86_64
ln -sv lib ././lib/mangohud/x86_64-linux-gnu
ln -sv . ././lib/mangohud/lib/x86_64
ln -sv . ././lib/mangohud/lib/x86_64-linux-gnu
ln -sv lib32 ././lib/mangohud/i686
ln -sv lib32 ././lib/mangohud/i386-linux-gnu
ln -sv ../lib32 ././lib/mangohud/lib/i386-linux-gnu
ln -sv lib32 ././lib/mangohud/i686-linux-gnu
ln -sv ../lib32 ././lib/mangohud/lib/i686-linux-gnu
#ln -sv lib /usr/lib/mangohud/aarch64-linux-gnu
#ln -sv lib /usr/lib/mangohud/arm-linux-gnueabihf
cd ../../

# Build appimage with linuxdeploy
ARCH=x86_64 /squashfs-root/AppRun \
  --appdir ./AppDir \
  --executable /usr/bin/glxgears \
  --executable /usr/bin/vkcube \
  -d ./data/goverlay.desktop \
  -i ./data/icons/512x512/goverlay.png \
  --output appimage

# Remove AppImage that have all the libs
declare -r appimageName="$(ls ./*.AppImage)"
rm ./*.AppImage

# Workaround to remove libgdk-x11-2.0.so.0 and recreate AppImage
rm ./AppDir/usr/lib/libgdk-x11-2.0.so.0
wget "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
chmod a+x appimagetool-x86_64.AppImage
./appimagetool-x86_64.AppImage --appimage-extract
ARCH=x86_64 ./squashfs-root/AppRun ./AppDir

# Remove appimagetool-x86_64.AppImage
rm ./appimagetool-x86_64.AppImage

# Move AppImage to /target
mv ./*.AppImage /target/"$appimageName"

# Execute the CMD command by default in Dockerfile or what we pass as argument
exec "$@"
