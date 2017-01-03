defmodule Alphabetify do

  @hash_chars String.split("ABCDEFGHIJKLMNOPQRSTUVWXYZ", "", trim: true) # builds an array with each character

  def generate_hash do
    if Enum.uniq(String.split(last_hash, "", trim: true)) == [List.last(@hash_chars)] do
      rollover_hash(last_hash)
    else
      advance_hash(last_hash)
    end
  end

  def seed_hash(seed) do
    if String.length(seed) == 0, do: raise ArgumentError, message: "The seed cannot be empty"
    if Enum.all?(String.split(seed, "", trim: true), fn(ch) -> Enum.member?(@hash_chars, ch) end) do
      last_hash(seed)
      last_hash
    else
      raise ArgumentError, message: "The seed can only contain characters in #{List.to_string(@hash_chars)}"
    end
  end

  def last_hash do
    File.read!(last_hash_file)
  end

  defp last_hash(str) do
    File.write! last_hash_file, str
  end

  def get_next_char(char) do
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

  def pop_last_member(enum) do
    remaining_enum = Enum.slice(enum, 0..-2)
    popped_value = Enum.at(enum, -1)
    [remaining_enum, popped_value]
  end

  def last_hash_file do
    if Mix.env == :test do
      "last-hash-test.txt"
    else
      "last-hash.txt"
    end
  end

end
