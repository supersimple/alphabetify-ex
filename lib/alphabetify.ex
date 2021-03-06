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

  @hash_chars ?A..?Z |> Enum.map(fn ch -> <<ch>> end)
  @doc """
  This generates the next hash in the sequence.

  ## Examples
      iex> Alphabetify.seed_hash("AAAA")
      iex> Alphabetify.generate_hash
      "AAAB"
  """

  @spec generate_hash() :: String.t()

  def generate_hash do
    if Enum.uniq(String.split(last_hash(), "", trim: true)) == [List.last(@hash_chars)] do
      last_hash()
      |> rollover_hash()
    else
      last_hash()
      |> advance_hash()
    end
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

    if Enum.all?(String.split(seed, "", trim: true), fn ch -> Enum.member?(@hash_chars, ch) end) do
      last_hash(seed)
      last_hash()
    else
      raise ArgumentError,
        message: "The seed can only contain characters in #{List.to_string(@hash_chars)}"
    end
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

  defp last_hash(str) do
    {:ok, table} = last_hash_table() |> :dets.open_file(type: :set)
    ret = :dets.insert(table, {:last_hash, str})
    :dets.close(table)
    ret
  end

  defp get_next_char(char) do
    unless char == List.last(@hash_chars) do
      next_char =
        Enum.find_index(@hash_chars, fn x -> x == char end)
        |> Kernel.+(1)
        |> char_at

      next_char
    else
      List.first(@hash_chars)
    end
  end

  defp char_at(position) do
    Enum.at(@hash_chars, position)
  end

  defp rollover_hash(hash) do
    # when all chars == the last char in the @hash_chars list
    # roll it over and add one char (eg. ZZZ -> AAAA)
    new_hash =
      List.first(@hash_chars)
      |> String.duplicate(String.length(hash) + 1)

    last_hash(new_hash)
    new_hash
  end

  defp advance_hash(last_hash) do
    # Advance the last character
    # If that char had to rollover, advance the next to last character
    # repeat if necessary
    # return the new string
    # eg. AAZZ -> ABAA
    # eg. AADZ -> AAEA
    reversed_hash =
      String.reverse(last_hash)
      |> String.split("", trim: true)

    parts = Enum.split_while(reversed_hash, fn ch -> ch == List.last(@hash_chars) end)

    rolled_hash = rolled_hash(parts)
    advanced_char = advanced_char(parts)
    unchanged_hash = unchanged_hash(parts)

    new_hash =
      Enum.concat(rolled_hash, [advanced_char])
      |> Enum.concat(unchanged_hash)
      |> Enum.join()
      |> String.reverse()

    last_hash(new_hash)
    new_hash
  end

  defp rolled_hash(parts) do
    parts
    |> Tuple.to_list()
    |> List.first()
    |> Enum.map(fn ch -> get_next_char(ch) end)
  end

  defp advanced_char(parts) do
    parts
    |> Tuple.to_list()
    |> List.last()
    |> List.first()
    |> get_next_char
  end

  defp unchanged_hash(parts) do
    parts
    |> Tuple.to_list()
    |> List.last()
    |> Enum.slice(1..-1)
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
