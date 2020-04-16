defmodule Codenamex.Game.Card do
  @moduledoc """
  This module manages the card logic.
  A card represents a word from the game, which has a color and can be touched.
  """

  @derive Jason.Encoder
  defstruct [
    word: nil,
    color: nil,
    touched: false
  ]

  def setup(word) do
    %__MODULE__{word: word}
  end

  def setup(word, color) do
    %__MODULE__{word: word, color: color}
  end

  def touchable?(%{touched: false}), do: true
  def touchable?(%{touched: true}), do: false

  def touch(card), do: %{card | touched: true}
end
