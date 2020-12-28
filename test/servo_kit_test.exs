defmodule ServoKitTest do
  use ExUnit.Case
  doctest ServoKit

  test "greets the world" do
    assert ServoKit.hello() == :world
  end
end
