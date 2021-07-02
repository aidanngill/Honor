defmodule Honor.Handler.Reaction.Remove do
  import Ecto.Query

  alias Nostrum.Api

  alias Honor.Repo
  alias Honor.Util
  alias Honor.Stars
  alias Honor.Guilds
  alias Honor.Messages

  def handle(reaction) do
    execute(reaction.emoji.name, reaction)
  end

  def execute("⭐", reaction) do
    guild = Repo.get_by(Guilds, guild: reaction.guild_id)

    if guild != nil do
      Stars
      |> where(message: ^reaction.message_id, user: ^Util.fetch_user_safe(reaction))
      |> Repo.delete_all

      query = from s in Stars,
        where: s.guild == ^reaction.guild_id,
        where: s.message == ^reaction.message_id,

        select: {s.id}

      stars = Repo.all(query)
      post = Repo.get_by(Messages, message: reaction.message_id)

      if length(stars) >= guild.threshold do
        content = ":star: #{length(stars)} in <##{reaction.channel_id}>"
        Api.edit_message(guild.channel, post.pin, content: content)
      else
        Api.delete_message!(guild.channel, post.pin)
        Repo.delete!(post)
      end
    end
  end

  def execute(_any, _reaction) do
    :noop
  end
end