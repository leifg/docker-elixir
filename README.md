# Minimalistic Elixir image

## stable

Branch `stable` includes the latest stable version of Elixir Erlang. This branch will be tagged as `latest` in docker.

## master

Branch `master` will build Elixir and Erlang from the latest master on their git repos. This branch will be tagged as `edge` in docker.

The edge image will automatically built with every new commit to [elixir/elixir-lang](https://github.com/elixir-lang/elixir) and [erlang/otp](https://github.com/erlang/otp). See [blog post](http://blog.leif.io/continuous-elixir-builds-with-docker/) for behind the scenes.

## info

The Docker container provides a `info.txt` in the root directory with details about the build
