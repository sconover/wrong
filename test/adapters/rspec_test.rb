here = File.expand_path(File.dirname(__FILE__))

require "open3"
require "fileutils"

require "./test/test_helper"
require "wrong/adapters/minitest"
require "bundler"

include Wrong

# Okay, this looks like RSpec but it's actually minitest
describe "testing rspec" do

  [1, 2].each do |rspec_version|
    it "version #{rspec_version}" do
      dir = "#{here}/rspec#{rspec_version}"
      spec_output = nil
      Dir.chdir(dir) do
        clear_bundler_env
        FileUtils.rm "#{dir}/Gemfile.lock", :force => true

        sys "bundle check", :ignore do |output|
          unless output == "The Gemfile's dependencies are satisfied\n"
            sys "bundle install --gemfile=#{dir}/Gemfile --local"
          end
        end

        sys "bundle list" do |output|
          lines = output.split("\n")
          lines.grep(/rspec/) do |line|
            assert { line =~ /rspec[-\w]* \(#{rspec_version}\.[\w.]*\)/ }
          end
        end

        Bundler.with_clean_env do
          # RSpec v1 exits with 0 on failure :-( (as do older rubies)
          expected_status = (rspec_version == 1 || RUBY_VERSION =~ /^1\.8\./ || RUBY_VERSION == '1.9.1' ? :ignore : 1)
          spec_output = sys "ruby #{dir}/failing_spec.rb", expected_status
        end
      end

      assert { spec_output.include? "1 failure" }
      assert { spec_output.include? "Expected ((2 + 2) == 5), but" }
    end
  end
end
