rails new railsapp --skip-test-unit --skip-prototype
cd railsapp

echo "group :development, :test do
 gem 'rspec-rails', '2.0.0'
 gem 'wrong', :path => '../../..'
end
" >> Gemfile

bundle install
rails g rspec:install
# crazy in-place edit shell mojo
(rm spec/spec_helper.rb && awk 'NR==5 {print "require \"wrong/adapters/rspec\""}1' > spec/spec_helper.rb) < spec/spec_helper.rb

echo "
require './spec/spec_helper.rb'
describe 'wrong in rspec in rails' do
  it 'calls the wrong assert' do
    assert { 1 + 1 == 3}
  end
end
" > spec/wrong_spec.rb


