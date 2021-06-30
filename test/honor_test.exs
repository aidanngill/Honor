defmodule HonorTest do
  use ExUnit.Case
  doctest Honor

  test "greets the world" do
    assert Honor.hello() == :world
  end
end
