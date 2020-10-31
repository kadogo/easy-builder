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
4) You can exit your docker container with CTRL+D you will find the build result in <DIRECTORY>

## Application description

### MangoHud

* Image: Debian Buster is needed for the build to work
* It build an appimage and give the libraries in the mangohud directory

* You need to specify`MANGOHUDARCH` as `x86-64` or `x86`
* This environnement variable is needed because the AppImage load the right architecture library based on it.

* Tested on Debian Buster

### Yad

* Image: Debian Stretch
* It build an AppImage

* Tested on Debian Buster
