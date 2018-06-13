FROM clojure:lein-2.8.1-alpine

RUN apk -U --no-cache --allow-untrusted add \
    nodejs \
    grep \
    dbus \
    openssh-client \
    git \
    yarn \
    # Chromium with dependencies
    chromium \
    nss

# Minimize size
RUN apk del --purge --force linux-headers binutils-gold gnupg zlib-dev libc-utils
RUN rm -rf /var/lib/apt/lists/* \
    /var/cache/apk/* \
    /usr/share/man \
    /tmp/* \
    /usr/lib/node_modules/npm/man \
    /usr/lib/node_modules/npm/doc \
    /usr/lib/node_modules/npm/html \
    /usr/lib/node_modules/npm/scripts

RUN \
    # create machine-id for gitlab shared runners
    dbus-uuidgen > /var/lib/dbus/machine-id

RUN \
    # Create chromium wrapper with required flags
    mv /usr/bin/chromium-browser /usr/bin/chromium-browser-origin && \
    echo $'#!/usr/bin/env sh\n\
    chromium-browser-origin --no-sandbox --headless --disable-gpu $@' > /usr/bin/chromium-browser && \
    chmod +x /usr/bin/chromium-browser

ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROME_PATH=/usr/lib/chromium/

RUN npm install --silent --global karma-cli karma karma-cljs-test karma-chrome-launcher
