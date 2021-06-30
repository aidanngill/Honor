import Config

config :honor,
  ecto_repos: [Honor.Repo]

config :honor, Honor.Repo,
  database: System.get_env("HONOR_DB_NAME"),
  username: System.get_env("HONOR_DB_USER"),
  password: System.get_env("HONOR_DB_PASS"),
  hostname: System.get_env("HONOR_DB_HOST"),
  port: System.get_env("HONOR_DB_PORT")

config :nostrum,
  token: System.get_env("HONOR_TOKEN"),
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