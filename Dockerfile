FROM alpine:3.5
MAINTAINER Leif Gensert <leif@leif.io>

ARG DISABLED_APPS='megaco wx debugger jinterface orber reltool observer gs et'
ARG ERLANG_TAG=OTP-20.0.2
ARG ELIXIR_TAG=v1.5.0

LABEL erlang_version=$ERLANG_TAG erlang_disabled_apps=$DISABLED_APPS elixir_version=$ELIXIR_TAG

RUN apk --update add --virtual run-dependencies ca-certificates ncurses openssl unixodbc

# install erlang

RUN set -xe \
    && apk --update add --virtual erlang-build-dependencies git ca-certificates build-base autoconf perl ncurses-dev openssl-dev unixodbc-dev tar \
    && cd /tmp \
    && git clone --branch $ERLANG_TAG --depth=1 --single-branch https://github.com/erlang/otp.git \
    && cd otp \
    && echo "ERLANG_BUILD=$(git rev-parse HEAD)" >> /info.txt \
    && echo "ERLANG_VERSION=$(cat OTP_VERSION)" >> /info.txt  \
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
      /tmp/*

# Install Elixir

RUN apk --update add --virtual elixir-build-dependencies git build-base \
    && cd /tmp \
    && git clone --branch $ELIXIR_TAG --depth=1 --single-branch https://github.com/elixir-lang/elixir.git \
    && cd elixir \
    && echo "ELIXIR_BUILD=$(git rev-parse HEAD)" >> /info.txt \
    && echo "ELIXIR_VERSION=$(cat VERSION)" >> /info.txt  \
    && make -j$(getconf _NPROCESSORS_ONLN) compile \
    && rm -rf .git \
    && make install \
    && apk del elixir-build-dependencies \
    && rm -rf \
      /var/cache/apk/* \
      /tmp/*

RUN echo cat /info.txt
RUN echo $ELIXIR_VERSION

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix hex.info

CMD ["/bin/sh"]
