defmodule HangmanTest do
  use ExUnit.Case

  alias Hangman.Impl.Game

  test "new game returns struct" do
    game = Game.new_game

    assert game.turns_left == 7
    assert game.game_state == :initial
    assert length(game.letters) > 0
  end

  test "new game returns correct word" do
    game = Game.new_game("testing")

    assert game.turns_left == 7
    assert game.game_state == :initial
    assert game.letters == String.codepoints("testing")
    assert game.letters
      |> Enum.join
      |> String.to_charlist
      |> Enum.all?(fn ch -> ch in ?a..?z end)
  end

  test "game won" do
    # given
    game = Game.new_game()
    game = Map.put(game, :game_state, :won)

    # when
    { new_game, _state } = Game.make_guess(game, "x")

    # then
    assert new_game == game
  end

  test "game lost" do
    # given
    game = Game.new_game()
    game = Map.put(game, :game_state, :lost)

    # when
    { new_game, _state } = Game.make_guess(game, "x")

    # then
    assert new_game == game
  end
end
