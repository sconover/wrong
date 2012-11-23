here = File.expand_path(File.dirname(__FILE__))

require "open3"
require "fileutils"

require "./test/test_helper"
require "wrong/adapters/minitest"

include Wrong

# If a new version of Rails comes along, alter and then run the script in this directory
# called rspec-rails-generate.sh -- if you dare


if RUBY_VERSION >= "1.9.2" # too many issues with other versions
describe "testing rspec-rails" do

  [2].each do |rspec_version|
    it "in rspec version #{rspec_version}" do
      railsapp_dir = "#{here}/railsapp"

      unless File.exist?(railsapp_dir)
        Dir.chdir(here) do
          clear_bundler_env
          sys "sh ./railsapp-gen.sh"
        end
      end

      spec_output = nil
      Dir.chdir(railsapp_dir) do
        clear_bundler_env
        FileUtils.rm "#{railsapp_dir}/Gemfile.lock", :force => true

        # todo: extract into common function
        sys "bundle check", :ignore do |output|
          unless output == "The Gemfile's dependencies are satisfied\n"
            sys "bundle install --gemfile=#{railsapp_dir}/Gemfile"
          end
        end

        # todo: extract into common function
        sys "bundle list" do |output|
          lines = output.split("\n")
          lines.grep(/rspec/) do |line|
            assert { line =~ /rspec[-\w]* \(#{rspec_version}\.[\w.]*\)/ }
          end
        end

        spec_output = sys "rspec spec/wrong_spec.rb",
                          (rspec_version == 1 || RUBY_VERSION =~ /^1\.8\./ || RUBY_VERSION == '1.9.1' ? :ignore : 1) # RSpec v1 exits with 0 on failure :-(
      end

      assert { spec_output.include? "1 example, 1 failure" }
      assert { spec_output.include? "Expected ((1 + 1) == 3), but" }
    end
  end
end
end
