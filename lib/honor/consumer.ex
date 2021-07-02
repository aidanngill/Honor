defmodule Honor.Consumer do
  use Nostrum.Consumer

  alias Honor.Handler.{Message, Reaction}

  def start_link do
    Consumer.start_link(__MODULE__, max_restarts: 0)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws}) do
    Message.Create.handle(msg)
  end

  def handle_event({:MESSAGE_REACTION_ADD, reaction, _ws}) do
    Reaction.Add.handle(reaction)
  end

  def handle_event({:MESSAGE_REACTION_REMOVE, reaction, _ws}) do
    Reaction.Remove.handle(reaction)
  end

  def handle_event(_event) do
    :noop
  end
end