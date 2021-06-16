defmodule ServoKit.MixProject do
  use Mix.Project

  @source_url "https://github.com/mnishiguchi/servo_kit"
  @version "0.2.0"

  def project do
    [
      app: :servo_kit,
      version: @version,
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      description: "Use PCA9685 PWM/Servo Controller in Elixir",
      deps: deps(),
      docs: docs(),
      package: package(),
      preferred_cli_env: []
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:circuits_i2c, "~> 0.1"},
      {:mox, "~> 1.0.0", only: :test},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  defp package() do
    [
      name: "servo_kit",
      files: [
        "lib",
        "mix.exs",
        "README.md",
        "LICENSE*"
      ],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "PCA9685 Data Sheet" => "https://cdn-shop.adafruit.com/datasheets/PCA9685.pdf",
        "PCA9685 Overview" =>
          "https://www.nxp.com/products/power-management/lighting-driver-and-controller-ics/ic-led-controllers/16-channel-12-bit-pwm-fm-plus-ic-bus-led-controller:PCA9685"
      }
    ]
  end
end
