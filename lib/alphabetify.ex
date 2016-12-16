defmodule Alphabetify do

  @hash_chars String.split("ABCDEFGHIJKLMNOPQRSTUVWXYZ", "", trim: true) # builds an array with each character

  def generate_hash do
    # traverse the last_hash from end to beginning. get_next_char for the last char. If that rolls over, get_next_char for the next-to-last char, etc. If all letters are rolled over, rollover_hash. write this to last_hash/1
    if Enum.uniq(String.split(last_hash, "", trim: true)) == [List.last(@hash_chars)] do
      rollover_hash(last_hash)
    else
      last_hash.reverse
      |> String.split("", trim: true)
      |> Enum.each(fn(ch) -> ch end)
    end

  end

  def seed_hash(seed) do
    if String.length(seed) == 0, do: raise ArgumentError, message: "The seed cannot be empty"
    if Enum.all?(String.split(seed, "", trim: true), fn(ch) -> Enum.member?(@hash_chars, ch) end) do
      last_hash(seed)
    else
      raise ArgumentError, message: "The seed can only contain characters in #{List.to_string(@hash_chars)}"
    end
  end

  defp last_hash do
    File.read!("last-hash.txt")
  end

  defp last_hash(str) do
    File.write! "last-hash.txt", str
  end

  defp get_next_char(char) do
    unless char == List.last(@hash_chars) do
      Enum.find_index(hash_chars, fn(x) -> x == char end)
      |> Kernel.+(1)
      |> [char_at, false]
    else
      [List.first(@hash_chars), true]
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

end
