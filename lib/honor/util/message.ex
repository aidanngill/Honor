defmodule Honor.Util.Message do
  import Ecto.Query

  alias Nostrum.Cache.GuildCache
  alias Nostrum.Cache.ChannelCache
  alias Nostrum.Struct.Guild.Member

  alias Honor.{Repo, Stars}

  def context_from_argument(value) do
    [_full_match, raw_id] = Regex.run(~r/<#(\d+)>/, value)
    {id, ""} = Integer.parse(raw_id, 10)

    channel = ChannelCache.get!(id)

    {:ok, GuildCache.get!(channel.guild_id), channel}
  end

  def has_permissions(message, permissions) do
    guild = GuildCache.get!(message.guild_id)
    member = Map.get(guild.members, message.author.id)
    member_permissions = Member.guild_permissions(member, guild)

    Enum.all? permissions, fn x -> x in member_permissions end
  end

  def is_command?(prefix, msg) do
    String.starts_with?(msg.content, prefix)
  end

  def unique_stars(guild_id) do
    Stars
    |> where(guild: ^guild_id)
    |> distinct([:message])
    |> Repo.all
  end
end