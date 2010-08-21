"Feels so right, it can't be Wrong"

## Abstract ##

Wrong provides a general assert method that takes any Ruby block.  Assertion failure messages are rich in detail.

Wrong is alpha-quality. We'd very much appreciate feedback and bug reports.

It relies on [Predicated](http://github.com/sconover/predicated) for its main failure message.

Inspired by [assert { 2.0 }](http://assert2.rubyforge.org/) but rewritten from scratch to be compatible with Ruby 1.8 and 1.9.

## Usage ##

Wrong provides a simple assert method that takes a block:

	require "wrong"
	
	include Wrong::Assert
	
	assert {1==1}
	 ==> nil
	
	assert {2==1}
	 ==> Wrong::Assert::AssertionFailedError: Expected (2 == 1), but 2 is not equal to 1

If your assertion is more than a simple predicate, then Wrong will split it into parts and show you the values of all the relevant subexpressions.

    x = 7; y = 10; assert { x == 7 && y == 11 }
     ==>
    Wrong::Assert::AssertionFailedError: Expected ((x == 7) and (y == 11)), but
        (x == 7) is true
        x is 7
        (y == 11) is false
        y is 10
    
And a companion, 'deny':

	deny{'abc'.include?('bc')}
	 ==> Wrong::Assert::AssertionFailedError: Didn't expect "abc".include?("bc"), but 'abc' includes 'bc'

There's also a convenience method for catching errors:

    assert{ catch_raise{raise "vanilla"}.message == "chocolate" }
	 ==>
    Wrong::Assert::AssertionFailedError: Expected (catch_raise { raise("vanilla") }.message == "chocolate"), but 'vanilla' is not equal to 'chocolate'

## Apology ##

So does the world need another assertion framework? In fact, it does not! We actually believe the world needs **fewer** assert methods.

The Wrong idea is to replace all those countless assert_this, assert_that library methods which only exist to give a more useful failure message than "assertion failed". Wrong replaces all of them in one fell swoop, since if you can write it in Ruby, Wrong can make a sensible failure message out of it.

Even the lowly workhorse `assert_equal` is bloated compared to Wrong: would you rather write this

    assert_equal time, money

or this

    assert { time == money }

? The Wrong version has the advantage of being plain, transparent Ruby code, not an awkward DSL that moves "equal" out of its natural place between the comparands. Plus, WYSIWYG! You know just from looking at it that "equal" means `==`, not `eql?` or `===` or `=~`.

Moreover, much like TDD itself, Wrong encourages you to write cleaner code. If your assertion messages are not clear and "Englishy", then maybe it's time for you to refactor a bit -- extract an informatively named variable or method, maybe push some function onto its natural object *a la* the [Law of Demeter](http://en.wikipedia.org/wiki/Law_of_Demeter)...

Wrong also lets you put the expected and actual values in any order you want! Consider the failure messages for

    assert { current_user == "joe" } # => Expected (current_user == "joe") but current_user is "fred"
    assert { "joe" == current_user } # => Expected ("joe" == current_user) but current_user is "fred"

You get just the information you want, and none you don't want. At least, that's the plan! :-)

## Algorithm ##

So wait a second. How do we do it? Doesn't Ruby have poor support for AST introspection? Well, yes, it does, so we cheat: we figure out what file and line the assert block is defined in, then open the file, read the code, and parse it directly using Ryan Davis' amazing [RubyParser](http://parsetree.rubyforge.org/ruby_parser/) and [Ruby2Ruby](http://seattlerb.rubyforge.org/ruby2ruby/). You can bask in the kludge by examining `chunk.rb` and `assert.rb`. If you find some code it can't parse, please send it our way.

Before you get your knickers in a twist about how this is totally unacceptable because it doesn't support this or that use case, here are our caveats and excuses:

* It works! Tested in 1.8.6, 1.8.7, 1.9.1, and 1.9.2-rc2. (Thank you, [rvm](http://rvm.beginrescueend.com/)!)
* It's a development-time library, not a production runtime library, so there are no security or filesystem issues. (If you're developing Ruby code without saving it to a mounted disk, then sorry, Wrong is not right for you.)
* `eval` isn't evil, it's just misunderstood.
* It makes a few assumptions about the structure of your code, leading to some restrictions:
  * You can't have more than one call to `assert` per line. (This should not be a problem since even if you're nesting asserts for some bizarre reason, we assume you know where your Return key is. And actually, technically you can put two asserts on a line, but it always describes the first one it sees, which means that if the second one executes, its failure message will be incorrect or broken.)
  * You can't use metaprogramming to write your assert blocks.
  * All variables and methods must be available in the binding of the assertion block.

## Helper Assert Methods ##

If you really want to, you can define your procs in one method, pass it in to another method, and have that method assert it. This is very bizarre and you probably shouldn't do it. Wrong will do its best to figure out where the actual assertion code is but it might not succeed.

If you're in Ruby 1.8, you **really** shouldn't do it! But if you do, you can use the "depth" parameter to give Wrong a better hint about how far up the stack it should crawl to find the code. See `assert_test.rb` for more details, if you dare.

## Adapters ##

Adapters for various test frameworks sit under wrong/adapters.

Currently we support
  * Test::Unit
  * Minitest

Coming soon
  * RSpec
  * ???

## Explanations ##

`assert` and `deny` can take an optional explanation, e.g.

      assert("since we're on Earth") { sky.blue? }

Since the point of Wrong is to make asserts self-explanatory, you should feel free to use explanations only when they would add something that you couldn't get from reading the (failed) assertion code itself. Don't bother doing things like this:

      assert("the sky should be blue") { sky.blue? } # redundant

The failure message of the above would be something like "Expected sky.blue? but sky is :green" which is not made clearer by the addition of "the sky should be blue". We already know it should be blue since we see right there that we're expecting it to be blue.

And if your assertion code isn't self-explanatory, then that's a hint that you might need to do some refactoring until it is. (Yes, even test code should be clean as a whistle. **Especially** test code.)

## Special Formatting ##

Enhancements for error messages sit under wrong/message.

Currently we support special messages for
  * String ==
  * Enumerable ==
    * including nested string elements

## Authors ##

* Steve Conover - <sconover@gmail.com>
* Alex Chaffee - <alex@stinky.com> - <http://alexch.github.com>

## Etc ##

Tracker project:
[http://www.pivotaltracker.com/projects/95014](http://www.pivotaltracker.com/projects/95014)
