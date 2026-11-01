require 'stringio'

Dir.chdir(File.dirname(File.realpath($0)))

PART = ARGV.shift&.then { Integer(it) }

$solves = []

def Object.method_added(name)
  $solves << instance_method(name) if self == Object && name == :solve
end

$test_count = 0

def test(*args, stdin: nil, file: nil)
  return if PART

  $test_count += 1

  ARGV.replace(args)
  input = stdin ? StringIO.new(stdin) : File.open(file)
  old_stdout = $stdout
  $stdout = StringIO.new
  begin
    $solves.last.bind_call(self, input)
    lines = $stdout.string.lines(chomp: true)
  ensure
    input.close
    $stdout = old_stdout
  end

  puts lines
  yield lines if block_given?
end

$has_assertion_failures = false

def fail_assertion(*details)
  warn '' if $has_assertion_failures
  $has_assertion_failures = true
  warn 'Assertion failed:'
  warn caller_locations(2, 1).first
  details.each { warn it }
end

def assert(*args)
  case args
  in [act]
    fail_assertion("\e[32m#{act.inspect}\e[0m")
  in [act, exp]
    fail_assertion("\e[31m#{exp.inspect}\e[0m", "\e[32m#{act.inspect}\e[0m") if act != exp
  end
end

at_exit do
  warn '' if $has_assertion_failures
  warn "test runs: #{$test_count}" if $test_count > 0

  $solves.fetch(PART - 1).bind_call(self, $stdin) if PART

  exit 1 if $has_assertion_failures
end
