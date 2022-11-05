FROM elixir:1.14

RUN addgroup --gecos 1000 elixir \
    && adduser --uid 1000 --ingroup elixir --disabled-password elixir

RUN apt-get update && apt-get install telnet

USER elixir

WORKDIR /home/elixir/backend