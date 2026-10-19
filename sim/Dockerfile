FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
      libwebkit2gtk-4.0-37 libsoup2.4-1 libusb-1.0-0 libsm6 libxext6 libxrender1 \
      libgtk-3-0 libglu1-mesa libpng16-16 libjpeg-turbo8 fonts-dejavu-core ca-certificates \
    && rm -rf /var/lib/apt/lists/*
