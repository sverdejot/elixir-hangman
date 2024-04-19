defmodule Hangman do

  alias Hangman.Impl.Game

  @type status :: :inital | :wont | :lost | :guessed | :not_guessed | :used
  @type game :: Game.t
  @type game_state :: %{
    turns_left: integer,
    status: status,
    letters: list(String.t),
    used: list(String.t),
  }

  @spec new_game :: game
  defdelegate new_game, to: Game 

  @spec make_guess(game, String.t) :: { game, game_state }
  def make_guess(_game, _guess) do
       
  end

end
