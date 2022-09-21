# easy-builder
Build multiple application with or without AppImage thanks to docker

## Notice

The AppImage doesn't contain system libraries, it can happen you see something like `symbol lookup error: ***: undefined symbol: g_module_open_full`. If that happen, you can make an issue or PR, but the easiest will be that you build the AppImage on your system (with or without Docker).

## How to use easy-builder

0) Install git and docker for your distribution

1) Clone the repository and go in the created directory

```
git clone https://github.com/kadogo/easy-builder.git
cd ./easy-builder
```

2) Generate your docker image

```
# Replace <APP> by the directory of the application you want build
# Replace <IMAGE> by the name you want for your docker image
docker build ./<APP>/ -t <IMAGE>
```

3) Use your image to build your application, the result of the build will be in your defined directory

```
# Replace <DIRECTORY> by the destination (the full path form not the relative) where you want to find the result of the build
docker run -it -v <FULL PATH DIRECTORY>/target:/target <YOUR IMAGE NAME>
```
4) You can exit your docker container with CTRL+D you will find the build result in `<FULL PATH DIRECTORY>`

## Application description

* [GOverlay](./goverlay/)
* [HandyMenu](./handymenu/)

### MangoHud

* Tested on Debian Buster

* Image: Debian Buster is needed for the build to work
* It build an AppImage and give the libraries in the mangohud directory

* The AppImage no need anymore that we specify the architecture
* The AppImage use internally `VK_LAYER_PATH` and `VK_INSTANCE_LAYERS` to activate MangoHud vulkan layer

### VkBasalt

* Tested on Debian Buster

* Image: Debian Bullseye is needed because it must be built with at least GCC 9
* It build an AppImage and give the libraries in the vkbasalt directory

* Because the build of GCC 9 the lib libstdc++ is built statically without that there will be an GLIBCXX error
* The AppImage use internally `VK_LAYER_PATH` and `VK_INSTANCE_LAYERS` to activate VkBasalt vulkan layer
* You can use `VKBASALT_CONFIG_FILE` to define the vkbasalt.conf

### Yad

* Tested on Debian Buster

* Image: Debian Stretch
* It build an AppImage
