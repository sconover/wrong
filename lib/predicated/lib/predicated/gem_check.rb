module Predicated
  def self.require_gem_version(gem_name, minimum_version, require_name=gem_name)
    unless Gem.available?(gem_name, Gem::Requirement.create(">= #{minimum_version}"))
      raise %{
Gem: #{gem_name} >=#{minimum_version}
Does not appear to be installed.  Please install it.

Predicated is built in a way that allows you to pick and 
choose which features to use.

RubyGems has no way to specify optional dependencies,
therefore I've made the decision not to have Predicated
automatically depend into the various gems referenced
in from/to "extensions".

The cost here is that the gem install doesn't necessarily 
"just work" for you out of the box.  But in return you get 
greater flexibility.  

Notably, rails/arel unfortunately has a hard dependency 
on Rails 3 activesupport, which requires ruby 1.8.7.  
By making from/to dependencies optional, those with 
no interest in arel can use Predicated in a wider 
variety of environments.

For more discussion see:
http://stackoverflow.com/questions/2993335/rubygems-optional-dependencies
}
    end
    
    require require_name
  end
  
end