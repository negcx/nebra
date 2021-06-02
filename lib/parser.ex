defmodule Parser do
  ### term

  ### expr

  ### factor
  def factor([{int, metadata} | tokens]) when is_integer(int),
    do: {tokens, {int, metadata, nil}}

  def factor([{number, metadata} | tokens]) when is_float(number),
    do: {tokens, {number, metadata, nil}}

  def factor([{string, metadata} | tokens]) when is_binary(string),
    do: {tokens, {string, metadata, nil}}

  def factor([{{:id, name}, metadata} | tokens]),
    do: {tokens, {{:id, name}, metadata, nil}}

  def factor([{:"(", metadata} | tokens]) do
  end

  {:term, [{:rule, :factor, :x}, :*, {:rule, :factor, :y}], {:*, [:x, :y]}}
  {:term, [{:rule, :factor, :x}, :/, {:rule, :factor, :y}], {:/, [:x, :y]}}
  {:term, [{:rule, :factor}, :x], :x}
end
