FROM alpine:3.5
MAINTAINER Leif Gensert <leif@leif.io>

ARG ERLANG_VERSION=19.3.3

LABEL name="erlang" version=$ERLANG_VERSION

# install erlang

ARG DISABLED_APPS='megaco wx debugger jinterface orber reltool observer gs et'
ARG ERLANG_DOWNLOAD_URL="https://github.com/erlang/otp/archive/OTP-${ERLANG_VERSION}.tar.gz"
ARG ERLANG_DOWNLOAD_SHA256="0f7247dc50c8a81897823f54f4a6daa3269d29c192a7eb594ea38722f6bb3bf3"

RUN set -xe \
    && apk --update add --virtual erlang-build-dependencies curl ca-certificates build-base autoconf perl ncurses-dev openssl-dev unixodbc-dev tar \
    && apk --update add ncurses openssl unixodbc \
    && curl -fSL -o otp-src.tar.gz "$ERLANG_DOWNLOAD_URL" \
    && echo "$ERLANG_DOWNLOAD_SHA256  otp-src.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/src/otp-src \
    && tar -xzf otp-src.tar.gz -C /usr/src/otp-src --strip-components=1 \
    && rm otp-src.tar.gz \
    && cd /usr/src/otp-src \
    && for lib in ${DISABLED_APPS} ; do touch lib/${lib}/SKIP ; done \
    && ./otp_build autoconf \
    && ./configure \
        --enable-smp-support \
        --enable-m64-build \
        --disable-native-libs \
        --enable-sctp \
        --enable-threads \
        --enable-kernel-poll \
        --disable-hipe \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && find /usr/local -name examples | xargs rm -rf \
    && apk del erlang-build-dependencies \
    && ls -d /usr/local/lib/erlang/lib/*/src | xargs rm -rf \
    && rm -rf \
      /opt \
      /var/cache/apk/* \
      /tmp/* \
      /usr/src

# Install Elixir

ENV ELIXIR_VERSION=1.4.2
ENV DOWNLOAD_SHA256=3ff610166612db10d3f97895972882a6912e99628e31116d22406389c1de48cc

LABEL name="elixir" version=$ELIXIR_VERSION

RUN apk --update add --virtual elixir-build-dependencies curl \
    && apk --update add --virtual run-dependencies ca-certificates \
    && curl -fSL -o elixir.zip https://github.com/elixir-lang/elixir/releases/download/v${ELIXIR_VERSION}/Precompiled.zip \
    && echo "$DOWNLOAD_SHA256 *elixir.zip" | sha256sum -c - \
    && mkdir -p /opt/elixir-${ELIXIR_VERSION}/ \
    && unzip elixir.zip -d /opt/elixir-${ELIXIR_VERSION}/ \
    && rm elixir.zip \
    && apk del elixir-build-dependencies \
    && rm -rf /var/cache/apk/*

RUN ln -s /opt/elixir-${ELIXIR_VERSION} /opt/elixir
RUN ln -s /opt/elixir/bin/elixir /usr/local/bin/elixir
RUN ln -s /opt/elixir/bin/elixirrc /usr/local/bin/elixirrc
RUN ln -s /opt/elixir/bin/mix /usr/local/bin/mix
RUN ln -s /opt/elixir/bin/iex /usr/local/bin/iex

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix hex.info

CMD ["/bin/sh"]
