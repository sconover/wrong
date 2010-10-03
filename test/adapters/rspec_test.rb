here = File.expand_path(File.dirname(__FILE__))

require "open3"
require "fileutils"

require "./test/test_helper"
require "wrong/adapters/minitest"

include Wrong

# Okay, this looks like RSpec but it's actually minitest
describe "testing rspec" do

  def sys(cmd, expected_status = 0)
    Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thread|
      # in Ruby 1.8.6, wait_thread is nil :-( so just pretend the process was successful (status 0)
      exit_status = (wait_thread.value.exitstatus if wait_thread) || 0
      output = stdout.read + stderr.read
      unless expected_status.nil?
        assert { output and exit_status == expected_status }
      end
      output
    end
  end

  def clear_bundler_env
    # Bundler inherits its environment by default, so clear it here
    %w{BUNDLE_PATH BUNDLE_BIN_PATH BUNDLE_GEMFILE}.each { |var| ENV.delete(var) }
  end

  [1, 2].each do |rspec_version|
    it "version #{rspec_version}" do
      dir = "#{here}/rspec#{rspec_version}"
      output = nil
      Dir.chdir(dir) do
        clear_bundler_env        
        FileUtils.rm "#{dir}/Gemfile.lock", :force => true
        output = sys "bundle install --gemfile=#{dir}/Gemfile --local"
        lines = output.split("\n")
        lines.grep(/rspec/) do |line|
          assert { line =~ /Using rspec[-\w]* \(#{rspec_version}\.[\w.]*\)/ }
        end

        output = sys "ruby #{dir}/failing_spec.rb",
                     (rspec_version == 1 || RUBY_VERSION == '1.8.6' || RUBY_VERSION == '1.9.1' ? nil : 1) # RSpec v1 exits with 0 on failure :-(
      end
      assert { output.include? "1 example, 1 failure" }
      assert { output.include? "Expected ((2 + 2) == 5), but" }
    end
  end
end

=begin
    # I would use
    #    out, err = capturing(:stdout, :stderr) do
    # but minitest does its own arcane stream munging and it's not working

    out = StringIO.new
    err = StringIO.new
    Spec::Runner.use(Spec::Runner::Options.new(out, err))

    module RSpecWrapper
      include Spec::DSL::Main
      describe "inside rspec land" do
        it "works" do
          sky = "blue"
          assert { sky == "green" }
        end
      end
    end

    Spec::Runner.options.parse_format("nested")
    Spec::Runner.options.run_examples

    assert(err.string.index(<<-RSPEC) == 0, "make sure the rspec formatter was used")
inside rspec land
  works (FAILED - 1)

1)
'inside rspec land works' FAILED
    RSPEC

    failures = Spec::Runner.options.reporter.instance_variable_get(:@failures) # todo: use my own reporter?
    assert !failures.empty?
    exception = failures.first.exception
    assert(exception.is_a?(Spec::Expectations::ExpectationNotMetError))
    assert(exception.message =~ /^Expected \(sky == \"green\"\), but/, "message is #{exception.message.inspect}")
  end
end
=end
