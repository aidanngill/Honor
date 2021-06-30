defmodule Honor.Consumer do
  use Nostrum.Consumer

  alias Honor.Command
  alias Honor.Reaction

  def start_link do
    Consumer.start_link(__MODULE__, max_restarts: 0)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws}) do
    Command.handle(msg)
  end

  def handle_event({:MESSAGE_REACTION_ADD, reaction, _ws}) do
    Reaction.handle_add(reaction)
  end

  def handle_event({:MESSAGE_REACTION_REMOVE, reaction, _ws}) do
    Reaction.handle_remove(reaction)
  end

  def handle_event(_event) do
    :noop
  end
end