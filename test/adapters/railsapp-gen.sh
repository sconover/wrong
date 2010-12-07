
# create a new rails app and change directories into it
rails new railsapp --skip-test-unit --skip-prototype
cd railsapp

# configure the rails app with the necessary libraries
echo "group :development, :test do
 gem 'rspec-rails', '~> 2.0'
 gem 'wrong', :path => '../../..'
end
" >> Gemfile
bundle install

# make it into an RSpec rails app
rails g rspec:install

# shell function to insert a line into a file
function insert {
  file=$1; shift
  line=$1; shift
  text=$*
  sed -i.bak -e "${line}i\\
$text
" $file
}

# insert a require line inside the generated spec_helper
line="require \"wrong/adapters/rspec\""
insert spec/spec_helper.rb 5 $line

# insert a spec file to run inside the rails app
echo "
require './spec/spec_helper.rb'
describe 'wrong in rspec in rails' do
  it 'calls the wrong assert' do
    assert { 1 + 1 == 3}
  end
end
" > spec/wrong_spec.rb
