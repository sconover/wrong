#simple (but slow) way to make sure requires are isolated
failed = Dir["test/**/*_test.rb"].collect do |test_file|
  ok = system("bundle exec ruby #{test_file}")
  test_file unless ok
end.compact
puts "suite " + (failed.empty? ? "passed" : "FAILED: #{failed.join(', ')}")
exit(failed.empty? ? 0 : 1)
