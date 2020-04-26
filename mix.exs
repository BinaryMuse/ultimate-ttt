defmodule UltimateTtt.MixProject do
  use Mix.Project

  def project do
    [
      app: :ultimate_ttt,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description:
        "This packages implements the rules of Ultimate Tic-Tac-Toe as well as an OTP app for creating and managing games.",
      source_url: "https://github.com/BinaryMuse/ultimate-ttt",

      # Package
      package: [
        licenses: ["MIT"],
        links: %{
          "GitHub" => "https://github.com/BinaryMuse/ultimate-ttt"
        }
      ],

      # Docs
      name: "Ultimate Tic-Tac-Toe",
      source_url: "https://github.com/BinaryMuse/ultimate-ttt",
      homepage_url: "https://github.com/BinaryMuse/ultimate-ttt",
      docs: [
        main: "readme",
        nest_modules_by_prefix: [UltimateTtt],
        extras: ["README.md": [filename: "readme", title: "README.md"]],
        before_closing_head_tag: &doc_styles/1
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  defp doc_styles(:html) do
    """
    <style>
    .content-inner code.text {
      font-family: Menlo, monospace;
      line-height: 1.3em;
    }
    </style>
    """
  end
end
