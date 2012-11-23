puts(if Object.const_defined? :RUBY_DESCRIPTION
  RUBY_DESCRIPTION
else
  "ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE} patchlevel #{RUBY_PATCHLEVEL}) [#{RUBY_PLATFORM}]"
end)

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift "#{dir}/../lib"

predicated_project_dir = File.expand_path("../predicated")
if File.exist?(predicated_project_dir) # if predicated project is a sibling of this project
  puts "using predicated from #{predicated_project_dir}"
  $LOAD_PATH.unshift "#{predicated_project_dir}/lib"
  require "predicated"
end

require "rubygems"
require "minitest/spec"
require "minitest/unit"
require "pp"

# yes, this does look a lot like Wrong::Assert#rescuing :-)
def get_error
  error = nil
  begin
    yield
  rescue Exception, RuntimeError => e
    error = e
  end
  error
end

def sys(cmd, expected_status = 0)
  start_time = Time.now
  $stderr.print cmd
  Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thread|
    # in Ruby 1.8, wait_thread is nil :-( so just pretend the process was successful (status 0)
    exit_status = (wait_thread.value.exitstatus if wait_thread) || 0
    output = stdout.read + stderr.read
    unless expected_status == :ignore
      assert(cmd) { cmd and output and exit_status == expected_status }
    end
    yield output if block_given?
    output
  end
ensure
  $stderr.puts " (#{"%.2f" % (Time.now - start_time)} sec)"
end

def clear_bundler_env
  # Bundler inherits its environment by default, so clear it here
  %w{BUNDLE_PATH BUNDLE_BIN_PATH BUNDLE_GEMFILE}.each { |var| ENV.delete(var) }
end

module Kernel
  def xdescribe(str)
    puts "x'd out describe \"#{str}\""
  end
end

class MiniTest::Spec
  include MiniTest::Assertions

  class << self
    def xit(str)
      puts "x'd out test \"#{str}\""
    end
  end
end

# dummy class for use by tests
class Color
  attr_reader :name
  def initialize(name)
    @name = name
  end

  def ==(other)
    other.is_a?(Color) && @name == other.name
  end

  def inspect
    "Color:#{@name}"
  end
end

MiniTest::Unit.autorun
