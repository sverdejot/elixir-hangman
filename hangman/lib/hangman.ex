defmodule Hangman do

  alias Hangman.Impl.Game
  alias Hangman.Type

  @type game :: Game.t

  @spec new_game :: game
  defdelegate new_game, to: Game 

  @spec make_guess(game, String.t) :: { game, Type.game_state }
  defdelegate make_guess(game, guess), to: Game

end
