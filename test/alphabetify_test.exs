defmodule AlphabetifyTest do
  use ExUnit.Case
  doctest Alphabetify

  test "the seed hash returns the seed" do
    assert "AAAA" == Alphabetify.seed_hash "AAAA"
  end

  test "the last hash returns the hash" do
    {:ok, table} = :dets.open_file(:alphabetify_disk_test_store, [type: :set])
    :dets.insert(table, {:last_hash, "AAAA"})
    :dets.close(:alphabetify_disk_test_store)
    assert "AAAA" == Alphabetify.last_hash()
  end

  test "generate hash from AAAA" do
    {:ok, table} = :dets.open_file(:alphabetify_disk_test_store, [type: :set])
    :dets.insert(table, {:last_hash, "AAAA"})
    :dets.close(:alphabetify_disk_test_store)
    assert "AAAB" == Alphabetify.generate_hash()
  end

  test "generate hash from ZZZZ" do
    {:ok, table} = :dets.open_file(:alphabetify_disk_test_store, [type: :set])
    :dets.insert(table, {:last_hash, "ZZZZ"})
    :dets.close(:alphabetify_disk_test_store)
    assert "AAAAA" == Alphabetify.generate_hash()
  end

  test "generate hash from AAAZ" do
    {:ok, table} = :dets.open_file(:alphabetify_disk_test_store, [type: :set])
    :dets.insert(table, {:last_hash, "AAAZ"})
    :dets.close(:alphabetify_disk_test_store)
    assert "AABA" == Alphabetify.generate_hash()
  end

  test "generate hash from AZZZZZZZZ" do
    {:ok, table} = :dets.open_file(:alphabetify_disk_test_store, [type: :set])
    :dets.insert(table, {:last_hash, "AZZZZZZZZZ"})
    :dets.close(:alphabetify_disk_test_store)
    assert "BAAAAAAAAA" == Alphabetify.generate_hash()
  end

end
