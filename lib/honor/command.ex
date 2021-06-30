defmodule Honor.Command do
  @prefix ">"

  alias Nostrum.Api

  alias Nostrum.Cache.GuildCache
  alias Nostrum.Cache.ChannelCache
  alias Nostrum.Struct.Guild.Member

  alias Honor.{
    Guilds,
    Repo
  }

  defp context_from_argument(value) do
    [_full_match, raw_id] = Regex.run(~r/<#(\d+)>/, value)
    {id, ""} = Integer.parse(raw_id, 10)

    channel = ChannelCache.get!(id)

    {:ok, GuildCache.get!(channel.guild_id), channel}
  end

  defp has_permissions(message, permissions) do
    guild = GuildCache.get!(message.guild_id)
    member = Map.get(guild.members, message.author.id)
    member_permissions = Member.guild_permissions(member, guild)

    Enum.all? permissions, fn x -> x in member_permissions end
  end

  defp is_command?(msg) do
    String.starts_with?(msg.content, @prefix)
  end

  def handle(msg) do
    if is_command?(msg) do
      msg.content
      |> String.trim()
      |> String.downcase()
      |> String.slice(String.length(@prefix)..-1)
      |> String.split(" ", parts: 3)
      |> execute(msg)
    end
  end

  def execute(["ping"], ctx) do
    Api.create_message(ctx.channel_id, "Pong!")
  end

  def execute(["channel", value], msg) do
    if has_permissions(msg, [:manage_channels]) do
      {:ok, guild, channel} = context_from_argument(value)

      if channel.guild_id == guild.id do
        result =
          case Repo.get_by(Guilds, guild: guild.id) do
            nil -> %Guilds{guild: guild.id, channel: channel.id}
            guild -> guild
          end
          |> Guilds.changeset(%{channel: channel.id})
          |> Repo.insert_or_update
        
        case result do
          {:ok, _struct} -> Api.create_message(
            msg.channel_id,
            "Updated the pin channel to <##{channel.id}> successfully."
          )

          {:error, _changeset} -> Api.create_message(
            msg.channel_id,
            "Failed to update the pin channel."
          )
        end
      end
    end
  end

  def execute(["threshold"], msg) do
    guild = Repo.get_by(Guilds, guild: msg.guild_id)
    threshold = if guild != nil do guild.threshold else 1 end

    Api.create_message(
      msg.channel_id,
      "#{threshold} star reacts are required to pin a message here."
    )
  end

  def execute(["threshold", value], msg) do
    if has_permissions(msg, [:manage_channels]) do
      {new_value, ""} = Integer.parse(String.replace(value, ~r/[^\d]/, ""), 10)

      if new_value >= 1 do
        result =
          case Repo.get_by(Guilds, guild: msg.guild_id) do
            nil -> %Guilds{guild: msg.guild_id}
            guild -> guild
          end
          |> Guilds.changeset(%{threshold: new_value})
          |> Repo.insert_or_update
        
        case result do
          {:ok, _struct} -> Api.create_message(
            msg.channel_id,
            "Updated the threshold successfully."
          )

          {:error, _changeset} -> Api.create_message(
            msg.channel_id,
            "Unknown error occured while updating threshold."
          )
        end
      else
        Api.create_message(
          msg.channel_id,
          "Please enter a number above zero!"
        )
      end
    end
  end

  def execute(["invite"], _msg) do
    :noop
  end

  def execute(["random"], _msg) do
    :noop
  end

  def execute(_any, _msg) do
    :noop
  end
end