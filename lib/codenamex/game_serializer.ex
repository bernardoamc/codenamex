defmodule Codenamex.GameSerializer do
  @moduledoc """
  This module serializes Game actions
  All the functions are used to return something to our channels.
  """

  alias Codenamex.Game.BoardSerializer

  @keys [
    :status,
    :winner,
    :turn,
    :over,
  ]

  def serialize(:state, game, "regular") do
    game
    |> Map.take(@keys)
    |> Map.put_new(:board, BoardSerializer.serialize(:state, game.board, "regular"))
  end

  def serialize(:state, game, "spymaster") do
    game
    |> Map.take(@keys)
    |> Map.put_new(:board, BoardSerializer.serialize(:state, game.board, "spymaster"))
  end

  def serialize(:touch_card, game) do
    Map.take(game, [:touched_card | @keys])
  end
end
