require "rubygems"
require "bundler"
Bundler.setup

task :default => :test

def separate
  Dir["./test/adapters/*_test.rb"] +
    [
      "./test/message/test_context_test.rb",
      "./test/assert_advanced_test.rb",
    ]
end

def sys cmd
  puts "$ #{cmd}"
  Bundler.with_clean_env do
    system cmd
  end
end

desc 'run all tests (in current ruby)'
task :test do
  return_values = separate.collect do |test_file|
    puts "\n>> Separately running #{test_file} under #{ENV['RUBY_VERSION']}..."
    sys("ruby #{test_file}")
  end

  return_values += [
    {"./test/adapters/minitest_test.rb" => "./Gemfile-minitest1"},
    {"./test/adapters/minitest_test.rb" => "./Gemfile-minitest5"},
    {"./test/adapters/test_unit_test.rb" => "./Gemfile-testunit"},
  ].collect do |pair|
    test_file = pair.keys.first
    gemfile = pair.values.first
    puts "\n>> Separately running #{test_file} under #{gemfile} and #{ENV['RUBY_VERSION']}..."
    sys("BUNDLE_GEMFILE=#{gemfile} bundle exec ruby #{test_file}")
  end
  all_passed = return_values.uniq == [true]
  at_exit { exit false } unless all_passed
  Rake::Task[:test_most].invoke
end

task :test_most do
  puts "\n>> Running most tests under #{ENV['RUBY_VERSION']}..."
  Dir["./test/**/*_test.rb"].each do |test_file|
    begin
      require test_file unless separate.include?(test_file)
    rescue Exception => e
      puts "Exception while requiring #{test_file}: #{e.inspect}"
      raise e
    end
  end
  # MiniTest::Unit.new.run(%w{-v})  # not needed due to MiniTest::Unit.autorun in test_helper.rb
end

desc 'run all tests (in current ruby) one at a time'
task :suite do
  puts "#{ENV['RUBY_VERSION']} - #{`which ruby`}"
  sh "ruby test/suite.rb"
end

# def clear_bundler_env
#   # Bundler inherits its environment by default, so clear it here
#   %w{BUNDLE_PATH BUNDLE_BIN_PATH BUNDLE_GEMFILE}.each { |var| ENV.delete(var) }
# end

namespace :rvm do
  require 'rvm'

  # todo: use https://gist.github.com/674648 technique instead
  #  $: << ENV["HOME"] + "/.rvm/lib"
  require 'rvm'

  @rubies=['1.8.6',
           '1.8.7',
           '1.9.1-p378', # we can't use p429 or p431, see http://bugs.ruby-lang.org/issues/show/3584 and http://bugs.ruby-lang.org/issues/2404
           '1.9.2',
           '1.9.3',
           '2.0.0',
           '2.1.4',
           'jruby']
  @rubies_str = @rubies.join(', ')

  def rvm
    @rvm_path ||= begin
      rvm = `which rvm`.strip
      raise 'rvm not available; go to http://rvm.io' unless rvm
      rvm
    end
  end

  def rvm_run(cmd, options = {})
    options = {:bundle_check => true}.merge(options)
    @rubies.each do |version|

      available_versions = RVM.list_strings
      version = available_versions.grep(/#{version}/).last

      puts "\n== Using #{version}"
      using = `#{rvm} #{version} exec true`
      if using =~ /not installed/
        puts "== #{using}"
      else
        if options[:bundle_check]
          Bundler.with_clean_env do
            prefix = "#{rvm} #{version} exec"
            sys "#{prefix} bundle check"
            if $?.exitstatus != 0
              sys("#{prefix} bundle install")
              sys("#{prefix} bundle install --gemfile=#{File.dirname __FILE__}/test/adapters/rspec1/Gemfile")
              sys("#{prefix} bundle install --gemfile=#{File.dirname __FILE__}/test/adapters/rspec2/Gemfile")
            end
          end
        end

        Bundler.with_clean_env do
          sys "#{rvm} #{version} exec #{cmd}"
        end
      end
    end
  end

  desc "run all tests with rvm in #{@rubies_str}"
  task :test do
    rvm_run "bundle exec rake test"
    rvm_run "ruby ./test/suite.rb"
    rvm_run ""

    # todo: fail if any test failed
    # todo: figure out a way to run suite with jruby --1.9 (it's harder than you'd think)
  end

  task :install => [:install_bundler, :install_gems]

  desc "run 'gem install bundler' with rvm in each of #{@rubies_str}"
  task :install_bundler do
    rvm_run("gem install bundler", :bundle_check => false)
  end
end

def load_gemspec(gemspec_name)
  gemspec_file = File.expand_path("../#{gemspec_name}.gemspec", __FILE__)
  gemspec = eval(File.read(gemspec_file), binding, gemspec_file)
end

def gemspecs
  @gemspecs ||= [load_gemspec("wrong"), load_gemspec("wrong-java")]
end

desc "Build pkg/#{gemspecs.first.full_name}.gem"
task :build => "gemspec:validate" do
  FileUtils.mkdir_p "pkg"
  gemspecs.each do |gemspec|
    sh %{gem build #{gemspec.name}#{"-" + gemspec.platform.to_s unless gemspec.platform == Gem::Platform::RUBY}.gemspec}
    FileUtils.mv gemspec.file_name, "pkg"
  end
end

desc "Install the latest built #{gemspecs.first.name} gem"
task :install => :build do
  sh "gem install --local pkg/#{gemspecs.first.file_name}"
end

namespace :gemspec do
  desc 'Validate the gemspecs'
  task :validate do
    gemspecs.map(&:validate)
  end
end

desc "Release the current branch to GitHub and Gemcutter"
task :release => %w(release:tag release:gem)

namespace :release do
  task :tag do
    gemspec = gemspecs.first
    release_tag = "v#{gemspec.version}"
    sh "git tag -a #{release_tag} -m 'Tagging #{release_tag}'"
    sh "git push origin #{release_tag}"
  end

  task :gem => :build do
    gemspecs.each do |gemspec|
      sh "gem push pkg/#{gemspec.file_name}"
    end
  end
end
