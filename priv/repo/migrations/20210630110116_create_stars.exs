defmodule Honor.Repo.Migrations.CreateStars do
  use Ecto.Migration

  def change do
    create table(:stars) do
      add :guild, :bigint
      add :channel, :bigint
      add :message, :bigint
      add :user, :bigint
    end
  end
end