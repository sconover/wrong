require "rubygems"
require "bundler"
Bundler.setup

def gemspec
  @gemspec ||= begin
    gemspec_file = File.expand_path('../wrong.gemspec', __FILE__)
    gemspec = eval(File.read(gemspec_file), binding, gemspec_file)
  end
end

task :default => :test

desc 'run all tests (in current ruby)'
task :test do
  puts "#{ENV['RUBY_VERSION']} - #{`which ruby`}"

  separate = ["./test/adapters/rspec_test.rb", "./test/message/test_context_test.rb"]
  all_passed = separate.collect do |test_file|
    puts "\nRunning #{test_file} separately..."
    system("bundle exec ruby #{test_file}")
  end.uniq == [true]
  if !all_passed
    at_exit { exit false }
  end

  puts "\nRunning tests..."
  Dir["./test/**/*_test.rb"].each do |test_file|
    begin
      require test_file unless separate.include?(test_file)
    rescue Exception => e
      puts "Exception while requiring #{test_file}: #{e.inspect}"
      raise e
    end
  end
  MiniTest::Unit.new.run
end

desc 'run all tests (in current ruby) one at a time'
task :suite do
  puts "#{ENV['RUBY_VERSION']} - #{`which ruby`}"
  sh "ruby test/suite.rb"
end

namespace :rvm do

  @rubies='1.8.6,1.8.7,1.9.1,1.9.2,jruby'

  def rvm
    rvm = `which rvm`.strip
    raise 'rvm not available; go to http://rvm.beginrescueend.com' unless rvm
    rvm
  end

  def rvm_run(cmd)
    # Bundler inherits its environment by default, so clear it here
    %w{BUNDLE_PATH BUNDLE_BIN_PATH BUNDLE_GEMFILE}.each {|var| ENV.delete(var) }
    @rubies.split(',').each do |version|
      puts "\n== Using #{version}"
      using = `#{rvm} use #{version}`
      if using =~ /not installed/
        puts "== #{using}"
      else
        system "#{rvm} #{version} exec bundle check"
        if $?.exitstatus != 0
          puts "try rake rvm:install_bundler or rake rvm:install_gems"
        end
        system "#{rvm} #{version} exec #{cmd}"
        if $?.exitstatus == 7
          puts "try rake rvm:install_gems"
        elsif $?.exitstatus == 1

        end
      end
    end
  end

  desc "run all tests with rvm in #{@rubies}"
  task :test do
    rvm_run "ruby test/suite.rb"
  end

  desc "run 'bundle install' with rvm in each of #{@rubies}"
  task :install_gems do
    rvm_run("bundle install")
  end

  desc "run 'gem install bundler' with rvm in each of #{@rubies}"
  task :install_bundler do
    rvm_run("gem install bundler")
  end
end

desc "Build pkg/#{gemspec.full_name}.gem"
task :build => "gemspec:validate" do
  sh %{gem build wrong.gemspec}
  FileUtils.mkdir_p "pkg"
  FileUtils.mv gemspec.file_name, "pkg"
end

desc "Install the latest built gem"
task :install => :build do
  sh "gem install --local pkg/#{gemspec.file_name}"
end

namespace :release do
  task :tag do
    release_tag = "v#{gemspec.version}"
    sh "git tag -a #{release_tag} -m 'Tagging #{release_tag}'"
    sh "git push origin #{release_tag}"
  end

  task :gem => :build do
    sh "gem push pkg/#{gemspec.file_name}"
  end
end

desc "Release the current branch to GitHub and Gemcutter"
task :release => %w(release:tag release:gem)

namespace :gemspec do
  desc 'Validate the gemspec'
  task :validate do
    gemspec.validate
  end
end
