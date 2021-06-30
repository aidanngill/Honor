defmodule Honor.Repo.Migrations.AddThreshold do
  use Ecto.Migration

  def change do
    alter table(:guilds) do
      add :threshold, :integer, default: 1
    end
  end
end
