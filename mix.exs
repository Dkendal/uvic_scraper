defmodule UvicScraper.Mixfile do
  use Mix.Project

  def project do
    [app: :uvic_scraper,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:floki, :httpoison, :logger, :dbg] ++ dev_apps]
  end

  def dev_apps do
    case Mix.env do
      :dev -> [:reprise]
      _ -> []
    end
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:pattern_tap, "~> 0.2.1"},
      {:httpoison, "~> 0.5"},
      {:floki, "~> 0.0.5"},
      {:zipper_tree, github: "dkendal/zipper_tree", branch: "v2"},
      {:exvcr, "~> 0.3.5", only: :test},
      {:ex_spec, "~> 0.3.0", only: :test},
      {:dbg, only: [:dev, :test]},
      {:reprise, "~> 0.3.0", only: :dev},
      {:apex, "~>0.3.2", only: :dev}
    ]
  end
end
