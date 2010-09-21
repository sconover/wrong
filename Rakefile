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
  sh "ruby test/suite.rb"
end

rubies='1.8.6,1.8.7,1.9.1,1.9.2'
desc "run all tests with rvm, #{rubies}"
task :rvm_test do
  rvm = `which rvm`.strip
  raise 'rvm not available, go to http://rvm.beginrescueend.com' unless rvm
  sh "#{rvm} ruby,#{rubies} test/suite.rb"
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
