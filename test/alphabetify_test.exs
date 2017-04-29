defmodule AlphabetifyTest do
  use ExUnit.Case
  doctest Alphabetify

  test "the seed hash returns the seed" do
    assert "AAAA" == Alphabetify.seed_hash "AAAA"
  end

  test "the last hash returns the hash" do
    assert "AAAA" == Alphabetify.last_hash()
  end

  test "generate hash from AAAA" do
    assert "AAAB" == Alphabetify.generate_hash()
  end
end
