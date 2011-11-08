source :gemcutter

gem "ruby_parser"
gem "ruby2ruby"
gem "sexp_processor"
gem "predicated", '~> 0.2.1'
gem "diff-lcs"
gem "rake"

platforms :ruby do
  gem "sourcify", '~> 0.4'
  gem "file-tail", '~> 1.0' # Sourcify requires this but doesn't declare it
end

platforms :ruby_18 do
  gem "ParseTree"
end

group :development, :test do
  gem "bundler"
  gem "rake"
  gem "minitest", "~> 1.7.2"
  gem "test-unit", "~> 2.1.1"
end

platforms :jruby do
  gem "jruby-openssl" # to silence annoying warning
end
