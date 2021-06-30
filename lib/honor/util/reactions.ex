defmodule Honor.Util.Reactions do
  import Nostrum.Struct.Embed

  defp create_message_link(guild_id, message) do
    "https://discord.com/channels/#{guild_id}/#{message.channel_id}/#{message.id}"
  end

  defp add_attachments(embed, nil), do: embed

  defp add_attachments(embed, attachments) do
    attachment = Enum.at(attachments, 0)

    if attachment != nil do
      put_image(embed, attachment.url)
    end

    embed
  end

  defp add_content(embed, nil), do: embed

  defp add_content(embed, content) do
    put_description(embed, content)
  end

  def create_embed(guild_id, message) do
    %Nostrum.Struct.Embed{}
    |> put_author(
        "#{message.author.username}##{message.author.discriminator}", nil,
        Nostrum.Struct.User.avatar_url(message.author)
      )
    |> put_timestamp(message.timestamp)
    |> put_field("Original", "[Click here](#{create_message_link(guild_id, message)})")
    |> add_content(message.content)
    |> add_attachments(message.attachments)
  end
end