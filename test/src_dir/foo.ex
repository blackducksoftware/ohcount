require 'bar'

#comment
  # comment with "string"

defmodule MyApp.Hello do
  @moduledoc """
  This is the Hello module.
  """
  @moduledoc since: "1.0.0"

  @doc """
  Says hello to the given `name`.

  Returns `:ok`.

  ## Examples

      iex> MyApp.Hello.world(:john)
      :ok

  """
  @doc since: "1.3.0"
  def world(name) do
    <<0, 42, 0>>
    IO.puts("hello #{name}")
  end
end

defmodule Person do
  @typedoc"""
  An example of type docs
  """

  defstruct name: '', age: 0      # similar to attr_accessor
  def dob, do: ...
end

person = %Person{ name: :foobar }  # create new struct.
