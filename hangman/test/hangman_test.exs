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

  test "letter already used" do
    # given
    game = Game.new_game()

    { game, _state } = Game.make_guess(game, "x")
    assert game.game_state != :used
    
    { game, _state } = Game.make_guess(game, "y")
    assert game.game_state != :used

    { game, _state } = Game.make_guess(game, "x")
    assert game.game_state == :used
    assert game.used == MapSet.new(["x", "y"])
  end

  test "guessed one letter" do
    game = Game.new_game("wombat")

    { game, _state} = Game.make_guess(game, "w")
    assert game.game_state == :guessed
  end

  test "guessed whole word" do
    game = Game.new_game("word")

    { game, _state} = Game.make_guess(game, "w")
    assert game.game_state == :guessed
  end

  test "not guessed" do
    game = Game.new_game("word")

    { game, _state} = Game.make_guess(game, "a")
    assert game.game_state == :not_guessed
  end

  test "lost game" do
    game = Game.new_game("wombat")

    { game, _state} = Game.make_guess(game, "c")
    { game, _state} = Game.make_guess(game, "d")
    { game, _state} = Game.make_guess(game, "f")
    { game, _state} = Game.make_guess(game, "g")
    { game, _state} = Game.make_guess(game, "h")
    { game, _state} = Game.make_guess(game, "i")
    { game, _state} = Game.make_guess(game, "j")

    assert game.game_state == :lost
  end

  test "won" do
    game = Game.new_game("wombat")

    { game, _state} = Game.make_guess(game, "w")
    { game, _state} = Game.make_guess(game, "o")
    { game, _state} = Game.make_guess(game, "m")
    { game, _state} = Game.make_guess(game, "b")
    { game, _state} = Game.make_guess(game, "a")
    { game, _state} = Game.make_guess(game, "t")

    assert game.game_state == :won
  end

  test "can handle moves" do
    [
      ["s", :guessed, 7, ["s", "_", "_", "_", "_", "_"], ["s"]],
      ["a", :guessed, 7, ["s", "a", "_", "_", "_", "_"], ["a", "s"]],
      ["x", :not_guessed, 6, ["s", "a", "_", "_", "_", "_"], ["a", "s", "x"]],
      ["m", :guessed, 6, ["s", "a", "m", "_", "_", "_"], ["a", "m", "s", "x"]],
    ]
      |> test_moves
  end

  defp test_moves(sequence) do
    game = Game.new_game("samuel")

    Enum.reduce(sequence, game, &check_move/2)
  end

  defp check_move([ letter, state, turns_left, letters, used ], game) do
    { game, new_state } = Game.make_guess(game, letter)
    
    assert new_state.game_state == state
    assert new_state.turns_left == turns_left
    assert new_state.letters == letters
    assert new_state.used == used
    
    game
  end

  test "can handle winning game" do
    [
      ["s", :guessed, 7, ["s", "_", "_", "_", "_", "_"], ["s"]],
      ["a", :guessed, 7, ["s", "a", "_", "_", "_", "_"], ["a", "s"]],
      ["x", :not_guessed, 6, ["s", "a", "_", "_", "_", "_"], ["a", "s", "x"]],
      ["m", :guessed, 6, ["s", "a", "m", "_", "_", "_"], ["a", "m", "s", "x"]],
      ["u", :guessed, 6, ["s", "a", "m", "u", "_", "_"], ["a", "m", "s", "u", "x"]],
      ["e", :guessed, 6, ["s", "a", "m", "u", "e", "_"], ["a", "e", "m", "s", "u", "x"]],
      ["l", :won, 6, ["s", "a", "m", "u", "e", "l"], ["a", "e", "l", "m", "s", "u", "x"]],
    ]
      |> test_moves
  end

  test "can handle loosing game" do
    [
      ["s", :guessed, 7, ["s", "_", "_", "_", "_", "_"], ["s"]],
      ["x", :not_guessed, 6, ["s", "_", "_", "_", "_", "_"], ["s", "x"]],
      ["y", :not_guessed, 5, ["s", "_", "_", "_", "_", "_"], ["s", "x", "y"]],
      ["z", :not_guessed, 4, ["s", "_", "_", "_", "_", "_"], ["s", "x", "y", "z"]],
      ["w", :not_guessed, 3, ["s", "_", "_", "_", "_", "_"], ["s", "w", "x", "y", "z"]],
      ["v", :not_guessed, 2, ["s", "_", "_", "_", "_", "_"], ["s", "v", "w", "x", "y", "z"]],
      ["t", :not_guessed, 1, ["s", "_", "_", "_", "_", "_"], ["s", "t", "v", "w", "x", "y", "z"]],
      ["b", :lost, 0, ["s", "_", "_", "_", "_", "_"], ["b", "s", "t", "v", "w", "x", "y", "z"]],
    ]
      |> test_moves
  end

end
