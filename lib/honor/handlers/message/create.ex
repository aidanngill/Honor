defmodule Honor.Handler.Message.Create do
  @prefix ">"

  import Nostrum.Struct.Embed

  alias Nostrum.Api
  alias Nostrum.Cache.Me

  alias Honor.{Guilds, Repo, Util}

  def handle(message) do
    if Util.Message.is_command?(@prefix, message) do
      message.content
      |> String.trim()
      |> String.downcase()
      |> String.slice(String.length(@prefix)..-1)
      |> String.split(" ", parts: 3)
      |> execute(message)
    end
  end

  def execute(["ping"], ctx) do
    Api.create_message(ctx.channel_id, "Pong!")
  end

  def execute(["channel", value], ctx) do
    if Util.Message.has_permissions(ctx, [:manage_channels]) do
      {:ok, guild, channel} = Util.Message.context_from_argument(value)

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
            ctx.channel_id,
            "Updated the pin channel to <##{channel.id}> successfully."
          )

          {:error, _changeset} -> Api.create_message(
            ctx.channel_id,
            "Failed to update the pin channel."
          )
        end
      end
    end
  end

  def execute(["threshold"], ctx) do
    guild = Repo.get_by(Guilds, guild: ctx.guild_id)
    threshold = if guild != nil do guild.threshold else 1 end

    Api.create_message(
      ctx.channel_id,
      "#{threshold} reactions are required to pin a message in this server."
    )
  end

  def execute(["threshold", value], ctx) do
    if Util.Message.has_permissions(ctx, [:manage_channels]) do
      amount = value
      |> String.replace(~r/[^\d]/, "")
      |> Integer.parse(10)

      case amount do
        :error ->
          Api.create_message(ctx.channel_id, "Please enter a valid number.")
        
        {new_value, _extra} when new_value > 0 ->
          result =
            case Repo.get_by(Guilds, guild: ctx.guild_id) do
              nil -> %Guilds{guild: ctx.guild_id}
              guild -> guild
            end
            |> Guilds.changeset(%{threshold: new_value})
            |> Repo.insert_or_update
          
          case result do
            {:ok, _struct} ->
              Api.create_message(
                ctx.channel_id,
                "Updated the threshold for this server to **#{new_value} reactions**."
              )
  
            {:error, _changeset} ->
              Api.create_message(
                ctx.channel_id,
                "Unknown error occured while updating threshold."
              )

          end
        
        _ ->
          Api.create_message(ctx.channel_id, "Please enter a valid number above zero.")

      end
    end
  end

  def execute(["random"], ctx) do
    post = ctx.guild_id
    |> Util.Message.unique_stars
    |> Enum.random

    if post != nil do
      case Api.get_channel_message(post.channel, post.message) do
        Nostrum.Error.ApiError ->
          Api.create_message(ctx.channel_id, "The message I found was deleted.")

        {:ok, message} ->
          url = Util.Reaction.create_message_link(post.guild, message)
          channel = Api.get_channel!(post.channel)

          embed = %Nostrum.Struct.Embed{}
          |> put_author(
              "#{message.author.username}##{message.author.discriminator}", nil,
              Nostrum.Struct.User.avatar_url(message.author)
            )
          |> put_description("[Click here!](#{url})")
          |> put_footer("##{channel.name}")
          |> put_timestamp(message.timestamp)
          
          Api.create_message(ctx.channel_id, embed: embed)
      end
    else
      Api.create_message(ctx.channel_id, "This server doesn't have any pins yet.")
    end
  end

  def execute(["invite"], ctx) do
    query = URI.encode_query(%{
      client_id: Me.get().id(),
      permissions: 84992,
      scope: "bot"
    })

    url_string =
      "https://discord.com/api/oauth2/authorize"
      |> URI.parse()
      |> Map.put(:query, query)
      |> URI.to_string()

    embed = %Nostrum.Struct.Embed{}
    |> put_description("You can invite me to your own server by clicking the link below.")
    |> put_field("Invite", "[Click here!](#{url_string})")

    Api.create_message(ctx.channel_id, embed: embed)
  end

  def execute(_any, _ctx) do
    :noop
  end
end