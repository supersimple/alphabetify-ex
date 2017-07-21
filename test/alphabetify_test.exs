defmodule AlphabetifyTest do
  use ExUnit.Case
  doctest Alphabetify

  test "the seed hash returns the seed" do
    assert "AAAA" == Alphabetify.seed_hash "AAAA"
  end

  test "the last hash returns the hash" do
    Alphabetify.last_hash("ACDC")
    assert "ACDC" == Alphabetify.last_hash()
  end

  test "generate hash from AAA" do
    Alphabetify.last_hash("AAA")
    assert "AAB" == Alphabetify.generate_hash()
  end

  test "generate hash from ZZZZ" do
    Alphabetify.last_hash("ZZZZ")
    assert "AAAAA" == Alphabetify.generate_hash()
  end

  test "generate hash from AAAZ" do
    Alphabetify.last_hash("AAAZ")
    assert "AABA" == Alphabetify.generate_hash()
  end

  test "generate hash from AZZZZZZZZ" do
    Alphabetify.last_hash("AZZZZZZZZZ")
    assert "BAAAAAAAAA" == Alphabetify.generate_hash()
  end
end
