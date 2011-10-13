## "Feels so right, it can't be Wrong"

![Someone is Wrong on the Internet](http://imgs.xkcd.com/comics/duty_calls.png)

## Abstract ##

Wrong provides a general assert method that takes a predicate block. Assertion failure messages are rich in detail. The Wrong idea is to replace all those countless `assert\_this`, `assert\_that`, `should\_something` library methods which only exist to give a failure message that's not simply "assertion failed". Wrong replaces all of them in one fell swoop, since if you can write it in Ruby, Wrong can make a sensible failure message out of it.

We'd very much appreciate feedback and bug reports. There are plenty of things left to be done to make the results look uniformly clean and beautiful. We want your feedback, and especially to give us cases where either it blows up or the output is ugly or uninformative.

Inspired by [assert { 2.0 }](http://assert2.rubyforge.org/) but rewritten from scratch. Compatible with Ruby (MRI) 1.8, 1.9, and JRuby 1.5.

## Installation

    gem install wrong

We have deployed gems for both Ruby and JRuby; if you get dependency issues on your platform, please let us know what Ruby interpreter and version you're using and what errors you get, and we'll try to track it down.

## Usage

Wrong provides a simple assert method that takes a block:

	require "wrong"   # or require "wrong/adapters/rspec" (see below)

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
	 ==> Didn't expect "abc".include?("bc")

More examples are in the file `examples.rb` <http://github.com/alexch/wrong/blob/master/examples.rb>

There's also a spreadsheet showing a translation from Test::Unit and RSpec to Wrong, with notes, at [this Google Doc](https://spreadsheets.google.com/pub?key=0AouPn6oLrimWdE0tZDVOWnFGMzVPZy0tWHZwdnhFYkE&hl=en&output=html). (Ask <alexch@gmail.com> if you want editing privileges.)

And don't miss the [slideshare presentation](http://www.slideshare.net/alexchaffee/wrong-5069976).

## Helper methods

### rescuing

There's also a convenience method for catching errors:

    assert{ rescuing{raise "vanilla"}.message == "chocolate" }
	 ==>
    Expected (rescuing { raise("vanilla") }.message == "chocolate"), but
        rescuing { raise("vanilla") }.message is "vanilla"
        rescuing { raise("vanilla") } is #<RuntimeError: vanilla>
        raise("vanilla") raises RuntimeError: vanilla

### capturing

And one for capturing output streams:

    assert { capturing { puts "hi" } == "hi\n" }
    assert { capturing(:stderr) { $stderr.puts "hi" } == "hi\n" }

    out, err = capturing(:stdout, :stderr) { ... }
    assert { out == "something standard\n" }
    assert { err =~ /something erroneous/ }

### close_to?

If you want to compare floats, try this:

    assert { 5.0.close_to?(5.0001) }   # default tolerance = 0.001
    assert { 5.0.close_to?(5.1, 0.5) } # optional tolerance parameter

If you don't want `close_to?` cluttering up `Float` in your test runs then use `include Wrong::Assert` instead of `include Wrong`.

### d

We also implement the most amazing debugging method ever, `d`, which gives you a sort of mini-wrong wherever you want it
, even in production code at runtime:

    require 'wrong'
    x = 7
    d { x } # => prints "x is 7" to the console
    d { x * 2 } # => prints "(x * 2) is 14" to the console
    d("math is hard") { 2 + 2 } #=> prints "math is hard: (2 + 2) is 4"

`d` was originally implemented by Rob Sanheim in LogBuddy; as with Assert2 this version is a rewrite and homage. You may also enjoy [g](https://github.com/jugyo/g) by [jugyo](http://jugyo.org/).

Remember, if you want `d` to work at runtime (e.g. in a webapp) then you must `include Wrong::D` inside your app, e.g. in your `environment.rb` file.

### eventually

If you care that something is going to be true *soon*, but maybe not *right* now, use `eventually`. It will keep executing the block, up to 4 times a second, until either

  * the block returns true(ish)
  * 5 seconds elapse

If the block raises an exception, then `eventually` will treat that as a false and keep trying. The last time it fails, it'll raise that exception instead of a mere `AssertionFailedError`. That way, the following are all possible:

    eventually { false }
    eventually { assert { false } }
    eventually { false.should be_true }  # in RSpec

and you should get the expected failure after time expires.

You can also send options to eventually as hash parameters.

    eventually(:timeout => 10) { false } # keep trying for 10 sec
    eventually(:delay => 1) { false }    # try every 1.0 sec, not every 0.25 sec

(For now, `eventually` is in its own module, but you get it when you `include Wrong`. Maybe it should be in Helpers like the rest?)

## Test Framework Adapters ##

Adapters for various test frameworks sit under wrong/adapters.

Currently we support

  * Test::Unit - `require 'wrong/adapters/test_unit'`
  * Minitest - `require 'wrong/adapters/minitest'`
  * RSpec - `require 'wrong/adapters/rspec'` (now supports both 1.3 and 2.0)

To use these, put the appropriate `require` in your helper, **after** requiring your test framework; it should extend the framework enough that you can use `assert { }` in your test cases without extra fussing around.

For example:

    require "test/unit"
    require "wrong/adapters/test_unit"
    class PlusTest < Test::Unit::TestCase
      def test_adding_two_and_two
        assert { 2 + 2 == 4 }
      end
    end

---

    require "rspec"
    require "wrong/adapters/rspec"
    describe "plus" do
      it "adds two and two" do
        assert { 2 + 2 == 4 }
      end
    end

## Piecemeal Usage ##

We know that sometimes you don't want all the little doodads from a library cluttering up your namespace. If you **don't** want to do

    require 'wrong'
    include Wrong

then you can instead `require` and `include` just the bits you really want. For example:

    require 'wrong/assert'
    include Wrong::Assert

will give you the `assert` and `deny` methods but not the formatters or `rescuing` or `d` or `close_to?`. And if all you want is `d` then do:

    require 'wrong/d'
    include Wrong::D

To summarize: if you do `require 'wrong'` and `include Wrong` then you will get the whole ball of wax. Most people will probably want this since it's easier, but there is an alternative, which is to `require` and `include` only what you want.

And beware: if you don't `require 'wrong'`, then `include Wrong` will not do anything at all.

## Gotcha: Side Effects Within the Assert Block ##

Be careful about making calls within the assert block that cause state changes.

    @x = 1
    def increment
      @x += 1
    end

    assert { increment == 2 }
    assert { increment == 2 }
     ==> Expected (increment == 2), but
         increment is 5

The first time increment fires the result is 2.  The second time the result is 3, and then Wrong introspects the block to create a good failure message, causing increment to fire a couple more times.

Confusing, we know!  A few patient Wrong users have hit this when the assert involves ActiveRecord write methods like #create! and #save.

The fix: introduce a variable:

    value = increment
    assert { value == 2 }
    assert { value == 2 }

## Apology ##

So does the world need another assertion framework? In fact, it does not! We actually believe the world needs **fewer** assert methods.

The Wrong idea is to replace all those countless assert\_this, assert\_that, should\_something library methods which only exist to give a more useful failure message than "assertion failed". Wrong replaces all of them in one fell swoop, since if you can write it in Ruby, Wrong can make a sensible failure message out of it.

Even the lowly workhorse `assert_equal` is bloated compared to Wrong: would you rather write this

    assert_equal time, money

or this

    assert { time == money }

? The Wrong way has the advantage of being plain, transparent Ruby code, not an awkward DSL that moves "equal" out of its natural place between the comparands. Plus, WYSIWYG! You know just from looking at it that "equal" means `==`, not `eql?` or `===` or `=~`.

Moreover, much like TDD itself, Wrong encourages you to write cleaner code. If your assertion messages are not clear and "Englishy", then maybe it's time for you to refactor a bit -- extract an informatively named variable or method, maybe push some function onto its natural object *a la* the [Law of Demeter](http://en.wikipedia.org/wiki/Law_of_Demeter)...
Also, try not to call any methods with side effects inside an assert. In addition to being bad form, this can cause messed-up failure messages, since the side effects may occur several times in the process of building the message.

Wrong also lets you put the expected and actual values in any order you want! Consider the failure messages for

    assert { current_user == "joe" } # => Expected (current_user == "joe") but current_user is "fred"
    assert { "joe" == current_user } # => Expected ("joe" == current_user) but current_user is "fred"

You get all the information you want, and none you don't want. At least, that's the plan! :-)

## BDD with Wrong ##

Wrong is compatible with RSpec and MiniTest::Spec, and probably Cucumber too, so you can use it inside your BDD framework of choice. To make your test code even BDD-er, try aliasing `assert` to either `should` or (Alex's favorite) `expect`.

Here's an RSpec example:

	require "wrong"
	require "wrong/adapters/rspec"
	Wrong.config.alias_assert :expect_that

	describe BleuCheese do
	  it "stinks" do
	    expect_that { BleuCheese.new.smell > 9000 }
	  end
	end

This makes your code read like a BDD-style DSL, without RSpec's "should" syntax (which is, let's face it, pretty weird the first few hundred times you have to use it). Compare

    expect_that { BleuCheese.new.smell > 9000 }

 to

    BleuCheese.new.smell.should > 9000

and consider which one more clearly describes the desired behavior. The object under test doesn't really have a `should` method, so why should it magically get one during a test? And in what human language is "should greater than" a valid phrase?

Warning: currently the use of `alias_assert :expect` is **not** compatible with RSpec, since RSpec also defines `expect` as a synonym for `lambda`. If you really want to use `expect` as an alias form `assert`, then use `Wrong.config.alias_assert :expect, :override => true`. See [issue #6](https://github.com/sconover/wrong/issues/6) for more details.

## Algorithm ##

So wait a second. How do we do it? Doesn't Ruby have [poor support for AST introspection](http://blog.zenspider.com/2009/04/parsetree-eol.html)? Well, yes, it does, so we cheat: we figure out what file and line the assert block is defined in, then open the file, read the code, and parse it directly using Ryan Davis' amazing [RubyParser](http://parsetree.rubyforge.org/ruby_parser/) and [Ruby2Ruby](http://seattlerb.rubyforge.org/ruby2ruby/). You can bask in the kludge by examining `chunk.rb` and `assert.rb`. If you find some code it can't parse, please send it our way. As a failsafe we also use Sourcify, which has yet another home baked RACC parser, so we have many chances to parse your code.

Before you get your knickers in a twist about how this is totally unacceptable because it doesn't support this or that use case, here are our caveats and excuses:

* It works! Tested in MRI 1.8.6, 1.8.7, 1.9.1, 1.9.2, and JRuby 1.5.3. (Thank you, [rvm](http://rvm.beginrescueend.com/)!)
* Your code needs to be in a file.
  * If you're developing Ruby code without saving it to a mounted disk, then sorry, Wrong is not right for you.
  * We monkey-patch IRB so if you do `irb -rwrong` it'll save off your session in memory where Wrong can read it.
  * It'd be nice if it could work inside a `-e` block but as far as we can tell, there's no way to grab that `-e` source code from inside Ruby.
* It's a development-time testing library, not a production runtime library, so there are no security or filesystem issues.
* `eval` isn't evil, it's just misunderstood.
* It makes a few assumptions about the structure of your code, leading to some restrictions:
  * You can't have more than one call to `assert` per line. (This should not be a problem since even if you're nesting asserts for some bizarre reason, we assume you know where your Return key is.)
  * You can't use metaprogramming to write your assert blocks.
  * All variables and methods must be available in the binding of the assert block.
  * Passing a proc around and eventually calling assert on it might not work in some Ruby implementations.
* Beware of Side Effects! (See discussion elsewhere in this document.)
* "Doesn't all this parsing slow down my test run"?  No - this applies to failure cases only. If the assert block returns true then Wrong simply moves on.

## Explanations ##

`assert` and `deny` can take an optional explanation, e.g.

      assert("since we're on Earth") { sky.blue? }

Since the point of Wrong is to make asserts self-explanatory, you should use explanations only when they would add something that you couldn't get from reading the (failed) assertion code itself. Don't bother doing things like this:

      assert("the sky should be blue") { sky.blue? } # redundant

The failure message of the above would be something like "`Expected sky.blue? but sky is :green`" which is not made clearer by the addition of "`the sky should be blue`". We already know it should be blue since we see right there ("`Expected (sky.blue?)`") that we're expecting it to be blue.

And if your assertion code isn't self-explanatory, then that's a hint that you might need to do some refactoring until it is. (Yes, even test code should be clean as a whistle. **Especially** test code.)

## Details ##

When a failure occurs, the exception message contains all the details you might need to make sense of it. Here's the breakdown:

    Expected [CLAIM], but
      [FORMATTER]
      [SUBEXP] is [VALUE]
      ...

* CLAIM is the code inside your assert block, normalized
* If there is a formatter registered for this type of predicate, its output will come next. (See below.)
* SUBEXP is each of the subtrees of the claim, minus duplicates and truisms (e.g. literals).
* The word "is" is a very nice separator since it doesn't look like code, but is short enough to be easily visually parsed.
* VALUE is `eval(SUBEXP).inspect`, wrapped and indented if necessary to fit your console

We hope this structure lets your eyes focus on the meaningful values and differences in the message, rather than glossing over with stack-trace burnout. If you have any suggestions on how to improve it, please share them.

(Why does VALUE use `inspect` and not `to_s`? Because `inspect` on standard objects like String and Array are sure to show all relevant details, such as white space, in a console-safe way, and we hope other libraries follow suit. Also, `to_s` often inserts line breaks and that messes up formatting and legibility.)

Wrong tries to maintain indentation to improve readability. If the inspected VALUE contains newlines, or is longer than will fit on your console, the succeeding lines will be indented to a pleasant level.

Sometimes Wrong will not be able to evaluate a detail without raising an exception. This exception will be duly noted, which might be misleading. For example,

	a = [1,2,3,4]
	assert { a.all? {|i| i<4} }

would fail, since on the final pass, `(i < 4)` is false. But the error message is a bit vague:

	Wrong::Assert::AssertionFailedError: Expected a.all? { |i| (i < 4) }, but
	    i raises NameError: undefined local variable or method `i' for main:Object

In evaluating the inner expression, Wrong does not have access to the block parameter `i`, since `i` is not in the scope of the outer expression. A better way to write the assertion would be

    a = [1,2,3,4]
    a.each {|i| assert {i < 4}}

which gives

	Wrong::Assert::AssertionFailedError: Expected (i < 4), but
	    i is 4

## Formatters ##

Enhancements for error messages sit under wrong/message.

Currently we support special messages for

  * String ==
  * Array(ish) ==
    * including nested string elements

To use the Array formatter, you may also need to `gem install diff-lcs` (it's an optional dependency).

    require "wrong/message/string_comparison"
    assert { "the quick brown fox jumped over the lazy dog" ==
             "the quick brown hamster jumped over the lazy gerbil" }
     ==>
    Expected ("the quick brown fox jumped over the lazy dog" == "the quick brown hamster jumped over the lazy gerbil"), but
    Strings differ at position 16:
     first: ..."quick brown fox jumped over the lazy dog"
    second: ..."quick brown hamster jumped over the lazy gerbil"

---

    require "wrong/message/array_diff"
    assert { ["venus", "mars", "pluto", "saturn"] ==
             ["venus", "earth", "pluto", "neptune"] }
     ==>
    Expected (["venus", "mars", "pluto", "saturn"] == ["venus", "earth", "pluto", "neptune"]), but ["venus", "mars", "pluto", "saturn"] is not equal to ["venus", "earth", "pluto", "neptune"]

    array diff:
    ["venus", "mars" , "pluto", "saturn" ]
    ["venus", "earth", "pluto", "neptune"]
              ^                 ^

## Config ##

These settings can either be set at runtime on the `Wrong.config` singleton, or inside a `.wrong` file in the current directory or a parent. In the `.wrong` file just pretend every line is preceded with `Wrong.config.` -- e.g. if there's a setting called `ice_cream`, you can do any of these in your `.wrong` file

    ice_cream                           # => Wrong.config[:ice_cream] => true
    ice_cream = true                    # => Wrong.config[:ice_cream] => true
    ice_cream = "vanilla"               # => Wrong.config[:ice_cream] => "vanilla"

or any of these at runtime:

    Wrong.config.ice_cream              # => Wrong.config[:ice_cream] => true
    Wrong.config.ice_cream = true       # => Wrong.config[:ice_cream] => true
    Wrong.config.ice_cream = "vanilla"  # => Wrong.config[:ice_cream] => "vanilla"

### Color ###

Apparently, no test framework is successful unless and until it supports console colors. Call

    Wrong.config.color

in your test helper or rakefile or wherever, or put

    color

in your `.wrong` file and get ready to be **bedazzled**. If you need custom colors, let us know.

### Aliases ###

An end to the language wars! Name your "assert" and "deny" methods anything you want.

* In your code, use `Wrong.config.alias_assert` and `Wrong.config.alias_deny`
* In your `.wrong` file, put `alias_assert :expect` on a line by itself

Here are some suggestions:

    alias_assert :expect # warning: not compatible with RSpec
    alias_assert :should # This looks nice in RSpec
    alias_assert :confirm
    alias_assert :be

    alias_assert :is
    alias_deny :aint

    alias_assert :assure
    alias_deny :refute

    alias_assert :yep
    alias_deny :nope

    alias_assert :yay!
    alias_deny :boo!

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

* Mailing list: <http://groups.google.com/group/wrong-rb>
* Github project: <http://github.com/sconover/wrong>
* Tracker project: <http://www.pivotaltracker.com/projects/109993>
* the [Wrong way translation table (from RSpec and Test::Unit)](https://spreadsheets.google.com/pub?key=0AouPn6oLrimWdE0tZDVOWnFGMzVPZy0tWHZwdnhFYkE&hl=en&output=html). (Ask <alexch@gmail.com> if you want editing privileges.)
* the [Wrong slides](http://www.slideshare.net/alexchaffee/wrong-5069976) that Alex presented at Carbon Five and GoGaRuCo
