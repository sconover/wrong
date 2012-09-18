source :gemcutter

gem "ruby_parser", ">= 3.0.0.a6"
gem "ruby2ruby", ">= 2.0.0.b1"
gem "sexp_processor"
gem "predicated", '~> 0.2.6'
gem "diff-lcs"

platforms :ruby do
  gem "sourcify", '~> 0.4'
  gem "file-tail", '~> 1.0' # Sourcify requires this but doesn't declare it
end

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
