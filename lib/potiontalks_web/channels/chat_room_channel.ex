defmodule PotiontalksWeb.ChatRoomChannel do
  use PotiontalksWeb, :channel

  def join("chat_room:lobby", payload, socket) do
    if authorized?(payload) do
      # display recent messages when a user joins the channel
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (chat_room:lobby).
  # Calls Kernel.spawn/1 to handle handle traffic efficiently and Save each message as it comes in
  def handle_in("new_message", payload, socket) do
    spawn(fn -> save_message(payload) end)
    broadcast! socket, "new_message", payload
    {:noreply, socket}
  end

  # after socket has been connected
  def handle_info(:after_join, socket) do
    Potiontalks.Message.recent_messages()
    |> Enum.each(fn msg -> push(socket, "new_message", format_msg(msg)) end)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp save_message(message) do
  Potiontalks.Message.changeset(%Potiontalks.Message{}, message)
    |> Potiontalks.Repo.insert
  end

  defp format_msg(msg) do
    %{
      name: msg.name,
      message: msg.message
    }
  end
end
