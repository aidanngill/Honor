defmodule Honor.Repo.Migrations.CreateGuilds do
  use Ecto.Migration

  def change do
    create table(:guilds) do
      add :guild, :bigint
      add :channel, :bigint
    end
  end
end