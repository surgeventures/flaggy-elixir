File.mkdir_p(Application.get_env(:junit_formatter, :report_dir))
ExUnit.configure formatters: [JUnitFormatter, ExUnit.CLIFormatter]
ExUnit.start()
