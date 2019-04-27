# Bang

Bang simply adds dynamic bang(!) functions to your existing module functions with after-callback.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `bang` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:bang, "~> 0.1.0"}]
end
```

  2. Ensure `bang` is started before your application:

```elixir
def application do
  [applications: [:bang]]
end
```

## Usage

Bang uses accumulated approach by definition. So, you can define several bangs inside your module and can use different callback for each @bang function.

```elixir
defmodule SampleModule do
  use Bang

  # @bang {[list_of_func_name_arg_count_tuples], {CallbackModule, :callback_fn}}

  @bang {[welcome: 1, welcome: 2], {SampleModule, :titleize}}
  def welcome(name), do: "Welcome #{name}!"
  def welcome(prefix, name), do: "Welcome #{prefix}. #{name}!"

  @bang {[good_bye: 1, good_bye: 2], {SampleModule, :titleize}}
  def good_bye(name), do: "Good bye #{name}!"
  def good_bye(prefix, name), do: "Good bye #{prefix}. #{name}!"

  def titleize(str) do
    str
    |> String.split(" ")
    |> Enum.map(fn(word) -> String.capitalize(word) end)
    |> Enum.join(" ")
  end
end

SampleModule.welcome("john doe") |> SampleModule.titleize == SampleModule.welcome!("john doe")
```
The code above will add `welcome!: 1, welcome!:2, good_bye!: 1, good_bye!: 2` functions to the SampleModule

### How to add bang function to existing public functions list of the module?

Open your iex console with `iex -S mix` command and run for

```elixir
iex> SomeModule.__info__(:functions)
# will result with list of tuples
```
And then add bang function as usual using the output list.

```elixir
defmodule SomeModule
  use Bang

  ...
  @bang {[list_of_tuples], {SomeOtherModule, :func_name}}
  ...
end
```

## Contributing

### Issues, Bugs, Documentation, Enhancements

1) Fork the project

2) Make your improvements and write your tests.

3) Make a pull request.
