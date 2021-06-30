defmodule Honor.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :guild, :bigint
      add :message, :bigint
      add :pin, :bigint
    end
  end
end
