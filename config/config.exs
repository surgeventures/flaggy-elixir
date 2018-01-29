use Mix.Config

if Mix.env() == :test do
  config :junit_formatter, report_dir: "/tmp/flaggy-test-results/exunit"
end
