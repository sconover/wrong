source :rubygems

gemspec name: "wrong"

group :development, :test do
  gem "rvm"
  gem "bundler"
  gem "rake"
  gem "minitest", "~> 1.7.2"
  gem "test-unit", "~> 2.1.1"
end

platforms :jruby do
  gem "jruby-openssl" # to silence annoying warning
end
