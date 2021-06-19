if Version.compare(System.version(), "1.10.0") != :lt do
  Code.put_compiler_option(:warnings_as_errors, true)
end

ExUnit.start()
