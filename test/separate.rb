#simple (but slow) way to make sure requires are isolated
result = Dir["test/**/*_test.rb"].collect{|test_file| system("bundle exec ruby #{test_file}") }.uniq == [true]
puts "suite " + (result ? "passed" : "FAILED")
exit(result ? 0 : 1)
