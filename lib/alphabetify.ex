defmodule Alphabetify do
  @moduledoc """
  Alphabetify
  --------------------------
  Alphabetify is a module that generates sequential alphabetic hashes.
  ## Use
  Before generating hashes, you should seed the module with your initial hash.
  By default, the module will begin at 'AAAA'.
  To use a different initial hash, call the `seed_hash/1` function. Example: `Alphabetify.seed_hash("AAAAAA")`.

  Each time you want to get the next available hash, call `generate_hash/0`. Example: `Alphabetify.generate_hash`.
  That function will advance the hash and persist it, then return the new hash.

  The hash will append new characters when required.
  Examples: `'ZZZZ' -> 'AAAAA'` and `'AAAZ' -> 'AABA'`
  """

  @first_char ?A
  @last_char ?Z
  [_last_char | rest] = chars = Enum.to_list(@last_char..@first_char)
  @hash_chars chars |> Enum.reverse() |> Enum.map(fn ch -> <<ch>> end)

  for ch <- rest do
    defp get_next_char(unquote(ch)), do: unquote(ch) + 1
  end

  defp get_next_char(@last_char), do: @first_char

  def hash_chars, do: @hash_chars

  @doc """
  This generates the next hash in the sequence.

  ## Examples
      iex> Alphabetify.seed_hash("AAAA")
      iex> Alphabetify.generate_hash
      "AAAB"
  """

  @spec generate_hash() :: String.t()

  def generate_hash, do: generate_hash(last_hash())

  def generate_hash(last_hash) do
  # Advance the last character
  # If that char had to rollover, advance the next to last character
  # repeat if necessary
  # return the new string
  # eg. AAZZ -> ABAA
  # eg. AADZ -> AAEA
    reversed_hash = String.reverse(last_hash)

    {maybe_rollover, charlist} =
      for <<char <- reversed_hash>>, reduce: {true, []} do
        {rollover, previous_charlist} ->
          rollover_next = char == @last_char
          current_char = if rollover, do: get_next_char(char), else: char
          {rollover_next, [current_char | previous_charlist]}
      end

    new_hash =
      if maybe_rollover,
        do: [@first_char | charlist],
        else: charlist

    new_hash = List.to_string(new_hash)

    last_hash(new_hash)
    new_hash
  end

  @doc """
  This sets the initial value in the hash sequence.

  ## Examples
      iex> Alphabetify.seed_hash("BBBB")
      "BBBB"
  """

  @spec seed_hash(String.t()) :: String.t()

  def seed_hash(seed) do
    if String.length(seed) == 0, do: raise(ArgumentError, message: "The seed cannot be empty")

    for <<str <- seed>>, str < @first_char or str > @last_char do
      raise ArgumentError,
        message: "The seed can only contain characters in #{List.to_string(@hash_chars)}"
    end

    last_hash(seed)
    last_hash()
  end

  @doc """
  This gets the last hash used.

  ## Examples
      iex> Alphabetify.seed_hash("ABCD")
      iex> Alphabetify.last_hash
      "ABCD"
  """

  @spec last_hash() :: String.t()
  def last_hash do
    {:ok, table} = last_hash_table() |> :dets.open_file(type: :set)
    ret = :dets.lookup(table, :last_hash) |> Keyword.get(:last_hash, "AAAA")
    :dets.close(table)
    ret
  end

  @spec last_hash(String.t()) :: String.t()
  defp last_hash(str) do
    {:ok, table} = last_hash_table() |> :dets.open_file(type: :set)
    ret = :dets.insert(table, {:last_hash, str})
    :dets.close(table)
    ret
  end

  @doc """
  Returns the table name used for the current environment

  ## Examples
      iex> Alphabetify.last_hash_table()
      :alphabetify_disk_test_store
  """
  @spec last_hash_table() :: atom
  def last_hash_table do
    case Mix.env() do
      :test -> :alphabetify_disk_test_store
      _ -> :alphabetify_disk_store
    end
  end
end
