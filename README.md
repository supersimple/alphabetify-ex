# Alphabetify
[![Build Status](https://semaphoreci.com/api/v1/supersimple/alphabetify-ex/branches/master/badge.svg)](https://semaphoreci.com/supersimple/alphabetify-ex)

    Create an alphabetical hash. Taking an existing alphabetic hash (of any length),
    will return the next hash in sequence. If all characters in hash are rolled over,
    will append a new char (increase the length by 1.)
    eg. 'ZZZZ' -> 'AAAAA' eg. 'AAAZ' -> 'AABA'

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `alphabetify` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:alphabetify, "~> 1.0.0"}]
    end
    ```

  2. Ensure `alphabetify` is started before your application:

    ```elixir
    def application do
      [applications: [:alphabetify]]
    end
    ```

## Important
Version 1.0.0 uses dets to store the hash. If you are upgrading from an earlier version, you will want to seed your hash again to transfer your last used hash to the new data store.
