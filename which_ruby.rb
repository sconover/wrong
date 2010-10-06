if Object.const_defined? :RUBY_DESCRIPTION
  puts RUBY_DESCRIPTION
else
  puts "ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE} patchlevel #{RUBY_PATCHLEVEL}) [#{RUBY_PLATFORM}]"
end
