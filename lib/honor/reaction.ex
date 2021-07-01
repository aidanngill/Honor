defmodule Honor.Reaction do
  import Ecto.Query

  alias Nostrum.Api

  alias Honor.Repo
  alias Honor.Stars
  alias Honor.Guilds
  alias Honor.Messages
  alias Honor.Util.Reactions

  def handle_add(reaction) do
    add(reaction.emoji.name, reaction)
  end

  def handle_remove(reaction) do
    remove(reaction.emoji.name, reaction)
  end

  def add("⭐", reaction) do
    guild = Repo.get_by(Guilds, guild: reaction.guild_id)
    message = Api.get_channel_message!(reaction.channel_id, reaction.message_id)

    user = if reaction.user_id == nil do reaction.member.user.id else reaction.user_id end

    if guild do
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
          embed = Reactions.create_embed(reaction.guild_id, message)
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

  def add(_any, _reaction) do
    :noop
  end

  def remove("⭐", reaction) do
    guild = Repo.get_by(Guilds, guild: reaction.guild_id)

    if guild do
      entry = Repo.get_by(Stars,
        message: reaction.message_id,
        user: if reaction.user_id == nil do reaction.member.user.id else reaction.user_id end
      )

      if entry != nil do
        Repo.delete!(entry)
      end

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

  def remove(_any, _reaction) do
    :noop
  end
end