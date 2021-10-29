import Config

config :honor,
  ecto_repos: [Honor.Repo]

config :nostrum,
  num_shards: :auto,
  gateway_intents: [
    :guilds,
    :guild_messages,
    :guild_members,
    :guild_message_reactions,
    :guild_presences
  ]

config :porcelain,
  driver: Porcelain.Driver.Basic
