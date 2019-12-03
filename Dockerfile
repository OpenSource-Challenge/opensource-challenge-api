FROM elixir:1.8

EXPOSE 8080

RUN useradd -md /usr/src/app -u 1001 phoenix-app
RUN chown 1001:root /usr/src/app
USER 1001

WORKDIR /usr/src/app
ENV MIX_ENV prod
ENV PORT 8080
ENV HOME /usr/src/app

RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix.* /usr/src/app/
# Guardian requires the config files to compile..
COPY config/* /usr/src/app/config/

USER root

RUN find /usr/src/app -type d -exec chmod 777 {} \; && \
    find /usr/src/app -type f -exec chmod 666 {} \;

USER 1001

RUN mix deps.get --only prod && \
    mix deps.compile --only prod

COPY . /usr/src/app/
RUN mix compile && \
    mix compile.protocols

USER root

RUN find /usr/src/app -type d -exec chmod 777 {} \; && \
    find /usr/src/app -type f -exec chmod 666 {} \;

USER 1001

CMD mix ecto.migrate && iex -S mix phx.server
