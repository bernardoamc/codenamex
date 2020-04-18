defmodule Codenamex.Game.BoardSerializer do
  @moduledoc """
  This module serializes the Board state
  All the functions are used in conjuction to GameSerializer
  """

  @keys [
    :red_cards,
    :blue_cards
  ]

  def serialize(:state, board, "regular") do
    Map.take(board, @keys)
    |> Map.put_new(:cards, board.regular_cards)
  end

  def serialize(:state, board, "spymaster") do
    Map.take(board, @keys)
    |> Map.put_new(:cards, board.spymaster_cards)
  end
end
