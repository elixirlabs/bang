defmodule SampleTestModule do
  use Bang

  @bang {[welcome: 0, welcome: 1, welcome: 2], {SampleTestModule, :titleize}}

  def welcome, do: "welcome"
  def welcome(name), do: "Welcome #{name}!"
  def welcome(prefix, name), do: "Welcome #{prefix}. #{name}!"

  @bang {[good_bye: 1, welcome: 2], {SampleTestModule, :titleize}}
  def good_bye(name), do: "Good bye #{name}!"
  def good_bye(prefix, name), do: "Good bye #{prefix}. #{name}!"

  def titleize(str) do
    str
    |> String.split(" ")
    |> Enum.map(fn(word) -> String.capitalize(word) end)
    |> Enum.join(" ")
  end
end
