source :gemcutter

gem "ruby_parser"
gem "ruby2ruby"
gem "sexp_processor"
gem "predicated", '~> 0.2.1'
gem "diff"
gem "diff-lcs"

platforms :ruby do
  gem "sourcify", '~> 0.3.0'
  gem "file-tail" # Sourcify requires this but doesn't declare it
end

platforms :ruby_18 do
  gem "ParseTree"
end

group :development do
  gem "minitest"
  gem "test-unit"
  gem "rspec", '~> 1'
end
