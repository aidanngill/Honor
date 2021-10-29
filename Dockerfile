FROM elixir:1.12.3

RUN mkdir /opt/honor
COPY . /opt/honor
WORKDIR /opt/honor

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get

RUN rm -rf /opt/honor/_build

ENV MIX_ENV prod
RUN mix release

CMD _build/prod/rel/honor/bin/honor start