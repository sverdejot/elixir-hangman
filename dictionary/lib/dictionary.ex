defmodule Dictionary do
  @word_list "assets/words.txt"
    |> File.read!
    |> String.split(~r[\n], trim: true)

  def random_word do
    @word_list
      |> Enum.random
  end

  def map([], _func),           do: []
  def map([head | tail], func), do: [func.(head) | map(tail, func)]

  def sqrt(list), do: map(list, &(&1**2))

  def even([]),                     do: false
  def even([_even]),                do: true
  def even([_head, _head2 | tail]), do: even(tail)
end
