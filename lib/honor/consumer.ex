defmodule Honor.Consumer do
  use Nostrum.Consumer

  alias Honor.Handler.{Message, Reaction}

  def start_link do
    Consumer.start_link(__MODULE__, max_restarts: 0)
  end

  def handle_event({:MESSAGE_CREATE, message, _ws}) do
    Message.Create.handle(message)
  end

  def handle_event({:MESSAGE_DELETE, message, _ws}) do
    Message.Delete.handle(message)
  end

  def handle_event({:MESSAGE_REACTION_ADD, reaction, _ws}) do
    Reaction.Add.handle(reaction)
  end

  def handle_event({:MESSAGE_REACTION_REMOVE, reaction, _ws}) do
    Reaction.Remove.handle(reaction)
  end

  def handle_event({:MESSAGE_REACTION_REMOVE_ALL, reaction, _ws}) do
    Reaction.RemoveAll.handle(reaction)
  end

  def handle_event(_event) do
    :noop
  end
end