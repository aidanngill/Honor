defmodule Honor.Handler.Message.Delete do
  import Ecto.Query

  alias Nostrum.Api

  alias Honor.Repo
  alias Honor.Stars
  alias Honor.Guilds
  alias Honor.Messages

  def handle(message) do
    post = Repo.get_by(Messages, message: message.id)

    if post != nil do
      guild = Repo.get_by!(Guilds, guild: message.guild_id)

      Stars
      |> where(message: ^message.id)
      |> Repo.delete_all

      Api.delete_message!(guild.channel, post.pin)
      Repo.delete!(post)
    end
  end
end