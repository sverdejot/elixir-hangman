defmodule Hangman.Impl.Game do

  alias Hangman.Type

  @type t :: %__MODULE__{
    turns_left:   integer,
    game_state:   Type.game_state,
    letters:      list(String.t), 
    used:         MapSet.t(String.t),
  }
  defstruct(
    turns_left:   7,
    game_state:   :initial,
    letters:      [],
    used:         MapSet.new
  )

  @spec new_game :: t
  def new_game do
    new_game Dictionary.random_word
  end

  @spec new_game(String.t) :: t
  def new_game(word) do
    %__MODULE__{
      letters: word |> String.codepoints
    }
  end

  @spec make_guess(t, String.t) :: { t, Type.game_state }
  def make_guess(game = %{ game_state: state }, _guess) 
    when state in [:won, :lost] do
    game |> return_with_state
  end

  def make_guess(game, guess) do
    accept_guess(game, guess, MapSet.member?(game.used, guess)) 
      |> return_with_state
  end

  defp accept_guess(game, _guess, _already_used = true) do
    %{ game | game_state: :used }
  end

  defp accept_guess(game, guess, _already_used) do
    %{ game | used: MapSet.put(game.used, guess) }
      |> score_guess(Enum.member?(game.letters, guess))
  end

  defp score_guess(game, _scored = true) do
    %{ game | 
      game_state: game.letters
        |> MapSet.new
        |> MapSet.subset?(game.used)
        |> maybe_won
    }
  end

  defp score_guess(game = %{ turns_left: 1 }, _bad_guess) do
    %{ game | game_state: :lost, turns_left: 0 }
  end

  defp score_guess(game, _bad_guess) do
    %{ game | turns_left: game.turns_left - 1, game_state: :not_guessed }
  end

  defp maybe_won(true),   do: :won
  defp maybe_won(_false), do: :guessed

  defp game_state(game) do
    %{
      turns_left: game.turns_left,
      game_state: game.game_state,
      letters: game |> reveal_guessed_letters,
      used: game.used |> MapSet.to_list() |> Enum.sort
    }
  end

  def return_with_state(game), do: { game, game_state(game) }

  defp reveal_guessed_letters(game) do
    game.letters 
      |> Enum.map(fn letter -> MapSet.member?(game.used, letter) |> maybe_reveal(letter) end)
  end

  defp maybe_reveal(true, letter), do: letter
  defp maybe_reveal(_false, _letter), do: "_"

end
