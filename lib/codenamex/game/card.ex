defmodule Codenamex.Game.Card do
  @moduledoc """
  This module manages the card logic.
  A card represents a word from the game, which has a color and can be touched.
  """

  defstruct [
    color: nil,
    touched: false
  ]

  def touchable?(%{touched: false}), do: true
  def touchable?(%{touched: true}), do: false

  def touch(card), do: %{card | touched: true}
end
