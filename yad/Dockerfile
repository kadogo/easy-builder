FROM debian:stretch

# Install basic applications
RUN apt update
RUN apt install --force-yes --yes git wget

# Download linuxdeploy
COPY ./download-linuxdeploy.sh /download-linuxdeploy.sh
RUN bash /download-linuxdeploy.sh

# Install the dependencies
COPY ./dependencies.sh /dependencies.sh
RUN bash /dependencies.sh

# Build app
COPY ./build.sh /build.sh
RUN bash /build.sh

# Create appimage
COPY ./create-appimage.sh /create-appimage.sh
ENTRYPOINT /create-appimage.sh

# Entry point when run image
ENTRYPOINT [ "/bin/bash", "/create-appimage.sh" ]

# Default CMD if image is run
CMD [ "/bin/bash" ]
