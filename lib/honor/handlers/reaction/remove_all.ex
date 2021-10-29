defmodule Honor.Handler.Reaction.RemoveAll do
  import Ecto.Query

  alias Nostrum.Api

  alias Honor.Repo
  alias Honor.Stars
  alias Honor.Guilds
  alias Honor.Messages

  def handle(data) do
    post = Repo.get_by(Messages, message: data.message_id)

    if post != nil do
      Repo.get_by!(Guilds, guild: data.guild_id)
      |> Api.delete_message!(post.pin)

      Stars
      |> where(message: ^data.message_id)
      |> Repo.delete_all

      Repo.delete!(post)
    end
  end
end