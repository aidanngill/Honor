defmodule Honor.Repo do
  use Ecto.Repo,
    otp_app: :honor,
    adapter: Ecto.Adapters.Postgres
end

defmodule Honor.Guilds do
  use Ecto.Schema
  import Ecto.Changeset

  @fields [:guild, :channel, :threshold]

  schema "guilds" do
    field :guild, :integer
    field :channel, :integer
    field :threshold, :integer, default: 1
  end

  def changeset(guild, attrs) do
    guild
    |> cast(attrs, @fields)
    |> validate_required([:guild])
    |> unique_constraint([:guild, :channel])
  end
end

defmodule Honor.Stars do
  use Ecto.Schema

  schema "stars" do
    field :guild, :integer
    field :channel, :integer
    field :message, :integer
    field :user, :integer
  end
end

defmodule Honor.Messages do
  use Ecto.Schema

  schema "messages" do
    field :guild, :integer
    field :message, :integer
    field :pin, :integer
  end
end

defmodule Honor.Application do
  use Application

  def start(_type, _args) do
    children = [
      Honor.Consumer,
      Honor.Repo
    ]

    opts = [
      strategy: :one_for_one,
      name: Honor.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end
end