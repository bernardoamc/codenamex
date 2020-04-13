defmodule Codenamex.Game.Team do
  def pick_order() do
    ["red", "blue"] |> Enum.shuffle
  end
end
