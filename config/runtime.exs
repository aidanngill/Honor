import Config

config :honor, Honor.Repo,
  database: System.fetch_env!("POSTGRES_DB"),
  username: System.fetch_env!("POSTGRES_USER"),
  password: System.fetch_env!("POSTGRES_PASSWORD"),
  hostname: System.fetch_env!("POSTGRES_HOST"),
  port: System.fetch_env!("POSTGRES_PORT")

config :nostrum,
  token: System.fetch_env!("DISCORD_TOKEN")
