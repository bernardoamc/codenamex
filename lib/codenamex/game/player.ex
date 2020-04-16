defmodule Codenamex.Game.Player do
  @moduledoc """
  This module manages the player logic.
  A player is someone who is interacting with the game.
  """

  @derive Jason.Encoder
  defstruct [
    name: nil,
    spymaster: nil,
    regular: nil,
  ]

  def setup(name, "spymaster") do
    %__MODULE__{name: name, spymaster: true, regular: false}
  end

  def setup(name, "regular") do
    %__MODULE__{name: name, spymaster: false, regular: true}
  end

  def can_select_word?(%{spymaster: false}), do: true
  def can_select_word?(%{spymaster: true}), do: false

  def can_view_board_layout?(%{spymaster: false}), do: false
  def can_view_board_layout?(%{spymaster: true}), do: true
end
