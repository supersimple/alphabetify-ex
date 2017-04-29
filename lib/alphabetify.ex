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
  # TODO: Has to be a better way
  @hash_chars ?A..?Z |> Enum.map(fn(ch) -> <<ch>> end)
  @doc """
  This generates the next hash in the sequence.

  ## Examples
    iex> Alphabetify.generate_hash
    "AAAB"
  """

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
    iex> Alphabetify.seed_hash("AAAA")
    "AAAA"
  """

  def seed_hash(seed) do
    if String.length(seed) == 0, do: raise ArgumentError, message: "The seed cannot be empty"
    if Enum.all?(String.split(seed, "", trim: true), fn(ch) -> Enum.member?(@hash_chars, ch) end) do
      last_hash(seed)
      last_hash()
    else
      raise ArgumentError, message: "The seed can only contain characters in #{List.to_string(@hash_chars)}"
    end
  end

  @doc """
  This gets the last hash used.

  ## Examples
    iex> Alphabetify.last_hash
    "AAAA"
  """

  def last_hash do
    {:ok, table} = last_hash_table |> :dets.open_file([type: :set])
    ret = :dets.lookup(table, :last_hash) |> Keyword.get(:last_hash, "AAAA")
    :dets.close(table)
    ret
  end

  defp last_hash(str) do
    {:ok, table} = last_hash_table |> :dets.open_file([type: :set])
    ret = :dets.insert(table, {:last_hash, str})
    :dets.close(table)
    ret
  end

  defp get_next_char(char) do
    unless char == List.last(@hash_chars) do
      next_char = Enum.find_index(@hash_chars, fn(x) -> x == char end)
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
    List.first(@hash_chars)
    |> String.duplicate(String.length(hash) + 1)
  end

  defp advance_hash(last_hash) do
    # Advance the last character
    # If that char had to rollover, advance the next to last character
    # repeat if necessary
    # return the new string
    # eg. AAZZ -> ABAA
    # eg. AADZ -> AAEA
    reversed_hash = String.reverse(last_hash)
    |> String.split("", trim: true)

    parts = Enum.split_while(reversed_hash, fn(ch) -> ch == List.last(@hash_chars) end)

    rolled_hash = Tuple.to_list(parts) |> List.first |> Enum.map(fn(ch) -> get_next_char(ch) end)
    advanced_char = Tuple.to_list(parts) |> List.last |> List.first |> get_next_char
    unchanged_hash = Tuple.to_list(parts) |> List.last |> Enum.slice(1..-1)

    Enum.concat(rolled_hash, [advanced_char])
    |> Enum.concat(unchanged_hash)
    |> Enum.join
    |> String.reverse
  end

  def last_hash_table do
    case Mix.env do
      :test -> :alphabetify_disk_test_store
      _ -> :alphabetify_disk_store
    end
  end
end
