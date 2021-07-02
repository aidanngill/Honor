defmodule Honor.Handler.Reaction.Add do
  import Ecto.Query

  alias Nostrum.Api

  alias Honor.Repo
  alias Honor.Stars
  alias Honor.Guilds
  alias Honor.Messages

  alias Honor.Util
  alias Honor.Util.Reaction

  def handle(reaction) do
    execute(reaction.emoji.name, reaction)
  end

  def execute("⭐", reaction) do
    guild = Repo.get_by(Guilds, guild: reaction.guild_id)

    if guild != nil do
      user = Util.fetch_user_safe(reaction)
      message = Api.get_channel_message!(reaction.channel_id, reaction.message_id)

      starred = Repo.get_by(Stars,
        message: reaction.message_id,
        user: user
      )

      if starred == nil do
        Repo.insert %Stars{
          guild: reaction.guild_id,
          channel: message.channel_id,
          message: reaction.message_id,
          user: user
        }
      end

      query = from s in Stars,
        where: s.guild == ^reaction.guild_id,
        where: s.message == ^reaction.message_id,

        select: {s.id}

      stars = Repo.all(query)
      post = Repo.get_by(Messages, message: reaction.message_id)

      if length(stars) >= guild.threshold do
        content = ":star: #{length(stars)} in <##{reaction.channel_id}>"

        if post == nil do
          embed = Reaction.create_embed(reaction.guild_id, message)
          pin_message = Api.create_message!(guild.channel, content: content, embed: embed)

          Repo.insert %Messages{
            guild: reaction.guild_id,
            message: reaction.message_id,
            pin: pin_message.id
          }
        else
          Api.edit_message(guild.channel, post.pin, content: content)
        end
      end
    end
  end

  def execute(_any, _reaction) do
    :noop
  end
end