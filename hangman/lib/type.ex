defmodule Hangman.Type do
  @type status :: :inital | :won | :lost | :guessed | :not_guessed | :used

  @type game_state :: %{
    turns_left: integer,
    status: status,
    letters: list(String.t),
    used: list(String.t),
  }
end
