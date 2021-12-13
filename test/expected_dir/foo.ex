elixir	code	require 'bar'
elixir	blank	
elixir	comment	#comment
elixir	comment	  # comment with "string"
elixir	blank	
elixir	code	defmodule MyApp.Hello do
elixir	comment	  @moduledoc """
elixir	comment	  This is the Hello module.
elixir	comment	  """
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
