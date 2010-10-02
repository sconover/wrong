## "Feels so right, it can't be Wrong"

![Someone is Wrong on the Internet](http://imgs.xkcd.com/comics/duty_calls.png)

## Abstract ##

Wrong provides a general assert method that takes a predicate block. Assertion failure messages are rich in detail. The Wrong idea is to replace all those countless assert\_this, assert\_that, should\_something library methods which only exist to give a more useful failure message than "assertion failed". Wrong replaces all of them in one fell swoop, since if you can write it in Ruby, Wrong can make a sensible failure message out of it.

We'd very much appreciate feedback and bug reports. There are plenty of things left to be done to make the results look uniformly clean and beautiful. We want your feedback, and especially to give us cases where either it blows up or the output is ugly or uninformative.

It relies on [Predicated](http://github.com/sconover/predicated) for its main failure message.

Inspired by [assert { 2.0 }](http://assert2.rubyforge.org/) but rewritten from scratch. Compatible with Ruby (MRI) 1.8, 1.9, and JRuby 1.5.

## Usage ##

Wrong provides a simple assert method that takes a block:

	require "wrong"
	
	include Wrong
	
	assert { 1 == 1 }
	 ==> nil
	
	assert { 2 == 1 }
	 ==> Expected (2 == 1), but 2 is not equal to 1

If your assertion is more than a simple predicate, then Wrong will split it into parts and show you the values of all the relevant subexpressions.

    x = 7; y = 10; assert { x == 7 && y == 11 }
     ==>
    Expected ((x == 7) and (y == 11)), but
        (x == 7) is true
        x is 7
        (y == 11) is false
        y is 10

--

    age = 24
    name = "Gaga"
    assert { age >= 18 && ["Britney", "Snooki"].include?(name) }
     ==>
    Expected ((age >= 18) and ["Britney", "Snooki"].include?(name)), but
        (age >= 18) is true
        age is 24
        ["Britney", "Snooki"].include?(name) is false
        name is "Gaga"

And a companion, 'deny':

	deny{'abc'.include?('bc')}
	 ==> Didn't expect "abc".include?("bc"), but 'abc' includes 'bc'

There's also a convenience method for catching errors:

    assert{ rescuing{raise "vanilla"}.message == "chocolate" }
	 ==>
    Expected (rescuing { raise("vanilla") }.message == "chocolate"), but 'vanilla' is not equal to 'chocolate'

And one for capturing output streams:

    assert { capturing { puts "hi" } == "hi\n" }
    assert { capturing(:stderr) { $stderr.puts "hi" } == "hi\n" }

    out, err = capturing(:stdout, :stderr) { ... }
    assert { out == "something standard\n" }
    assert { err =~ /something erroneous/ }

If you want to compare floats, try this:

    assert { 5.0.close_to?(5.0001) }   # default tolerance = 0.001
    assert { 5.0.close_to?(5.1, 0.5) } # optional tolerance parameter

(If you don't want `close_to?` cluttering up `Float` in your test runs then use `include Wrong::Assert` instead of `include Wrong`.)

We also implement the most amazing debugging method ever, `d`, which gives you a sort of mini-wrong wherever you want it
, even in production code at runtime:

    require 'wrong'
    x = 7
    d { x } # => prints "x is 7" to the console
    d { x * 2 } # => prints "(x * 2) is 14" to the console

(`d` was originally implemented by Rob Sanheim in LogBuddy; as with Assert2 this is a rewrite and homage.)

More examples are in the file `examples.rb` <http://github.com/alexch/wrong/blob/master/examples.rb>

There's also a spreadsheet showing a translation from Test::Unit and RSpec to Wrong, with notes, at [this Google Doc](https://spreadsheets.google.com/pub?key=0AouPn6oLrimWdE0tZDVOWnFGMzVPZy0tWHZwdnhFYkE&hl=en&output=html). (Ask <alexch@gmail.com> if you want editing privileges.)

And don't miss the [slideshare presentation](http://www.slideshare.net/alexchaffee/wrong-5069976).

## Piecemeal Usage ##

We know that sometimes you don't want all the little doodads from a library cluttering up your namespace. If you **don't** do

    require 'wrong'
    include Wrong

then you can instead `require` and `include` just the bits you really want. For example:

    require 'wrong/assert'
    include Wrong::Assert

will give you the `assert` and `deny` methods but not the formatters or `rescuing` or `d` or `close_to?`. And if all you want is `d` then do:

    require 'wrong/d'
    include Wrong::D

To summarize: if you do `require 'wrong'` and `include Wrong` then you will get the whole ball of wax. Most people will probably want this since it's easier, but there is an alternative, whici is to `require` and `include` only what you want.

And beware: if you don't `require 'wrong'`, then `include Wrong` will not do anything at all.

## Apology ##

So does the world need another assertion framework? In fact, it does not! We actually believe the world needs **fewer** assert methods.

The Wrong idea is to replace all those countless assert\_this, assert\_that, should\_something library methods which only exist to give a more useful failure message than "assertion failed". Wrong replaces all of them in one fell swoop, since if you can write it in Ruby, Wrong can make a sensible failure message out of it.

Even the lowly workhorse `assert_equal` is bloated compared to Wrong: would you rather write this

    assert_equal time, money

or this

    assert { time == money }

? The Wrong way has the advantage of being plain, transparent Ruby code, not an awkward DSL that moves "equal" out of its natural place between the comparands. Plus, WYSIWYG! You know just from looking at it that "equal" means `==`, not `eql?` or `===` or `=~`.

Moreover, much like TDD itself, Wrong encourages you to write cleaner code. If your assertion messages are not clear and "Englishy", then maybe it's time for you to refactor a bit -- extract an informatively named variable or method, maybe push some function onto its natural object *a la* the [Law of Demeter](http://en.wikipedia.org/wiki/Law_of_Demeter)...

Wrong also lets you put the expected and actual values in any order you want! Consider the failure messages for

    assert { current_user == "joe" } # => Expected (current_user == "joe") but current_user is "fred"
    assert { "joe" == current_user } # => Expected ("joe" == current_user) but current_user is "fred"

You get just the information you want, and none you don't want. At least, that's the plan! :-)

## Algorithm ##

So wait a second. How do we do it? Doesn't Ruby have [poor support for AST introspection](http://blog.zenspider.com/2009/04/parsetree-eol.html)? Well, yes, it does, so we cheat: we figure out what file and line the assert block is defined in, then open the file, read the code, and parse it directly using Ryan Davis' amazing [RubyParser](http://parsetree.rubyforge.org/ruby_parser/) and [Ruby2Ruby](http://seattlerb.rubyforge.org/ruby2ruby/). You can bask in the kludge by examining `chunk.rb` and `assert.rb`. If you find some code it can't parse, please send it our way.

Before you get your knickers in a twist about how this is totally unacceptable because it doesn't support this or that use case, here are our caveats and excuses:

* It works! Tested in 1.8.6, 1.8.7, 1.9.1, and 1.9.2-rc2. (Thank you, [rvm](http://rvm.beginrescueend.com/)!)
* Your code needs to be in a file.
  * If you're developing Ruby code without saving it to a mounted disk, then sorry, Wrong is not right for you.
  * We monkey-patch IRB so if you do `irb -rwrong` it'll save off your session in a place Wrong can read it.
* It's a development-time testing library, not a production runtime library, so there are no security or filesystem issues.
* `eval` isn't evil, it's just misunderstood.
* It makes a few assumptions about the structure of your code, leading to some restrictions:
  * You can't have more than one call to `assert` per line. (This should not be a problem since even if you're nesting asserts for some bizarre reason, we assume you know where your Return key is. And actually, technically you can put two asserts on a line, but it always describes the first one it sees, which means that if the second one executes, its failure message will be incorrect or broken.)
  * You can't use metaprogramming to write your assert blocks.
  * All variables and methods must be available in the binding of the assertion block.

## Adapters ##

Adapters for various test frameworks sit under wrong/adapters.

Currently we support

  * Test::Unit - `require 'wrong/adapters/test_unit'`
  * Minitest - `require 'wrong/adapters/minitest'`
  * RSpec - `require 'wrong/adapters/rspec'`

To use these, put the appropriate `require` in your helper; it should extend the framework enough that you can use `assert { }` in your test cases without extra fussing around.

## Explanations ##

`assert` and `deny` can take an optional explanation, e.g.

      assert("since we're on Earth") { sky.blue? }

Since the point of Wrong is to make asserts self-explanatory, you should feel free to use explanations only when they would add something that you couldn't get from reading the (failed) assertion code itself. Don't bother doing things like this:

      assert("the sky should be blue") { sky.blue? } # redundant

The failure message of the above would be something like "`Expected sky.blue? but sky is :green`" which is not made clearer by the addition of "`the sky should be blue`". We already know it should be blue since we see right there ("`Expected (sky.blue?)`") that we're expecting it to be blue.

And if your assertion code isn't self-explanatory, then that's a hint that you might need to do some refactoring until it is. (Yes, even test code should be clean as a whistle. **Especially** test code.)

## Details ##

When a failure occurs, the exception message contains all the details you might need to make sense of it. Here's the breakdown:

    Expected [CLAIM], but [PREDICATE]
      [FORMATTER]
      [SUBEXP] is [VALUE]
      ...

* CLAIM is the code inside your assert block
* PREDICATE is a to-English translation of the claim, via the Predicated library. This tries to be very intelligible; e.g. translating "include?" into "does not include" and so on.
* If there is a formatter registered for this type of predicate, its output will come next. (See below.)
* SUBEXP is each of the subtrees of the claim, minus duplicates and truisms (e.g. literals).
* The word "is" is a very nice separator since it doesn't look like code.
* VALUE is `eval(SUBEXP).inspect`

We hope this structure lets your eyes focus on the meaningful values and differences in the message, rather than glossing over with stack-trace burnout. If you have any suggestions on how to improve it, please share them.

(Why does VALUE use `inspect` and not `to_s`? Because `inspect` on standard objects like String and Array are sure to show all relevant details, such as white space, in a console-safe way, and we hope other libraries follow suit. Also, `to_s` often inserts line breaks and that messes up formatting and legibility.)

## Formatters ##

Enhancements for error messages sit under wrong/message.

Currently we support special messages for

  * String ==
  * Enumerable ==
    * including nested string elements

To use these formatters, you have to explicitly `require` them! You may also need to `gem install diff-lcs` (since it's an optional dependency).

    require "wrong/message/string_diff"
    assert { "the quick brown fox jumped over the lazy dog" ==
             "the quick brown hamster jumped over the lazy gerbil" }
     ==>
    Expected ("the quick brown fox jumped over the lazy dog" == "the quick brown hamster jumped over the lazy gerbil"), but "the quick brown fox jumped over the lazy dog" is not equal to "the quick brown hamster jumped over the lazy gerbil"

    string diff:
    the quick brown fox jumped over the lazy dog
                    ^^^
    the quick brown hamster jumped over the lazy gerbil
                    ^^^^^^^
--

    require "wrong/message/array_diff"
    assert { ["venus", "mars", "pluto", "saturn"] ==
             ["venus", "earth", "pluto", "neptune"] }
     ==>
    Expected (["venus", "mars", "pluto", "saturn"] == ["venus", "earth", "pluto", "neptune"]), but ["venus", "mars", "pluto", "saturn"] is not equal to ["venus", "earth", "pluto", "neptune"]

    array diff:
    ["venus", "mars" , "pluto", "saturn" ]
    ["venus", "earth", "pluto", "neptune"]
              ^                 ^

[Bug: turns out 'diff' and 'diff-lcs' are incompatible with each other. We're working on a fix.]

## Color ##

Apparently, no test framework is successful unless and until it supports console colors. So now we do. Put

    Wrong.config[:color] = true

in your test helper or rakefile or wherever and get ready to be **bedazzled**. If you need custom colors, let us know.

## Aliases ##

An end to the language wars! Name your "assert" and "deny" methods anything you want. Here are some suggestions:

      Wrong.config.alias_assert(:expect)
      Wrong.config.alias_assert(:should) # This looks nice with RSpec
      Wrong.config.alias_assert(:confirm)
      Wrong.config.alias_assert(:be)

      Wrong.config.alias_assert(:is)
      Wrong.config.alias_deny(:aint)

      Wrong.config.alias_assert(:assure)
      Wrong.config.alias_deny(:refute)

      Wrong.config.alias_assert(:yep)
      Wrong.config.alias_deny(:nope)

      Wrong.config.alias_assert(:yay!)
      Wrong.config.alias_deny(:boo!)

Just don't use "`aver`" since we took that one for an internal method in `Wrong::Assert`.

## Helper Assert Methods ##

If you really want to, you can define your proc in one method, pass it in to another method, and have that method assert it. This is a challenge for Wrong and you probably shouldn't do it. Wrong will do its best to figure out where the actual assertion code is but it might not succeed.

If you're in Ruby 1.8, you **really** shouldn't do it! But if you do, you can use the "depth" parameter to give Wrong a better hint about how far up the stack it should crawl to find the code. See `assert_test.rb` for more details, if you dare.

## Authors ##

* Steve Conover - <sconover@gmail.com>
* Alex Chaffee - <alex@stinky.com> - <http://alexch.github.com>
* John Firebaugh
* Thierry Henrio

## Etc ##

* Github projects: <http://github.com/alexch/wrong>, <http://github.com/sconover/wrong>
* Tracker project: <http://www.pivotaltracker.com/projects/109993>
* the [Wrong way translation table (from RSpec and Test::Unit)](https://spreadsheets.google.com/pub?key=0AouPn6oLrimWdE0tZDVOWnFGMzVPZy0tWHZwdnhFYkE&hl=en&output=html). (Ask <alexch@gmail.com> if you want editing privileges.)
* the [Wrong slides](http://www.slideshare.net/alexchaffee/wrong-5069976) that Alex presented at Carbon Five and GoGaRuCo
