defmodule Codenamex.Game.Card do
  defstruct [
    color: nil,
    touched: false
  ]

  def touchable?(%{touched: false}), do: true
  def touchable?(%{touched: true}), do: false

  def touch(card), do: %{card | touched: true}
end
