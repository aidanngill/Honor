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
      guild = Repo.get_by!(Guilds, guild: data.guild_id)

      Stars
      |> where(message: ^data.message_id)
      |> Repo.delete_all

      Api.delete_message!(guild.channel, post.pin)
      Repo.delete!(post)
    end
  end
end