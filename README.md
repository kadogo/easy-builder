# easy-builder
Build multiple application with or without appimage with the help of docker

## Howto use easy-builder

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

3) Use your image to build your application the result of the build will be in your defined directory

```
# Replace <DIRECTORY> by the destination (the full path form not the relative) where you want to find the result of the build
docker run -it -v <DIRECTORY>/target:/target <IMAGE>
```
4) You can exit your docker container with CTRL+D you will find the build result in `<DIRECTORY>`

## Application description

* [GOverlay](./goverlay/)

### MangoHud

* Tested on Debian Buster

* Image: Debian Buster is needed for the build to work
* It build an AppImage and give the libraries in the mangohud directory

* The AppImage no need anymore that we specify the architecture
* The AppImage use internaly `VK_LAYER_PATH` and `VK_INSTANCE_LAYERS` to activate MangoHud vulkan layer

### VkBasalt

* Tested on Debian Buster

* Image: Debian Bullseye is needed because it must be build with at least GCC 9
* It build an AppImage and give the libraries in the vkbasalt directory

* Because the build of GCC 9 the lib libstdc++ is build staticaly without that there will be an GLIBCXX error
* The AppImage use internaly `VK_LAYER_PATH` and `VK_INSTANCE_LAYERS` to activate VkBasalt vulkan layer
* You can use `VKBASALT_CONFIG_FILE` to define the vkbasalt.conf

### Yad

* Tested on Debian Buster

* Image: Debian Stretch
* It build an AppImage
