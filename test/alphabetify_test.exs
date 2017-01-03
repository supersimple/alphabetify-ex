defmodule AlphabetifyTest do
  use ExUnit.Case
  doctest Alphabetify

  test "the seed hash returns the seed" do
    assert "AAAA" == Alphabetify.seed_hash "AAAA"
  end

  test "the last hash returns the hash" do
    File.write! Alphabetify.last_hash_file, "AAAA" #prepare the file for testing
    assert "AAAA" == Alphabetify.last_hash
  end

  test "generate hash" do
    File.write! Alphabetify.last_hash_file, "ZZZZ" #prepare the file for testing
    assert "AAAAA" == Alphabetify.generate_hash

    File.write! Alphabetify.last_hash_file, "AAAA" #prepare the file for testing
    assert "AAAB" == Alphabetify.generate_hash

    File.write! Alphabetify.last_hash_file, "AAAZ" #prepare the file for testing
    assert "AABA" == Alphabetify.generate_hash

    File.write! Alphabetify.last_hash_file, "AZZZZZZZZZ" #prepare the file for testing
    assert "BAAAAAAAAA" == Alphabetify.generate_hash
  end

end
