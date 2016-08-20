defmodule Bang.Mixfile do
  use Mix.Project

  def project do
    [app: :bang,
     version: "0.1.0",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package,
     description: description,
     docs: [extras: ["README.md"]]]
  end

  defp description do
    """
    Bang simply adds dynamic bang! functions to your existing module functions
    with after-callback.
    """
  end

  defp package do
    [name: :bang,
     files: ["lib", "mix.exs", "README.md"],
     maintainers: ["Mustafa Turan"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/mustafaturan/bang"}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, "~> 0.13.0", only: :dev}]
  end
end
