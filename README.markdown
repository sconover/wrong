## Abstract ##

Wrong provides a general assert method that takes any Ruby block.  Assertion failure messages are rich in detail.

Wrong is alpha-quality. We'd very much appreciate feedback and bug reports.

It relies on Predicated for its main failure message. <http://github.com/sconover/predicated>

Inspired by [assert { 2.0 }](http://assert2.rubyforge.org/) but rewritten from scratch to be compatible with Ruby 1.8 and 1.9.

## Usage ##

Wrong provides a simple assert method that takes a block:

	require "wrong"
	
	include Wrong::Assert
	
	assert{1==1} 
	 ==> nil
	
	assert{2==1}
	 ==> Wrong::Assert::AssertionFailedError: 2 is not equal to 1

If your assertion is more than a simple predicate, then Wrong will split it into parts and show you the values of all the relevant subexpressions.

    x = 7; y = 10; assert { x == 7 && y == 11 }
     ==>
    Wrong::Assert::AssertionFailedError: Expected ((x == 7) and (y == 11)), but This is not true: 7 is equal to 7 and 10 is equal to 11
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
        catch_raise { raise("vanilla") }.message is "vanilla"
        catch_raise { raise("vanilla") } is #<RuntimeError: vanilla>
        catch_raise is #<LocalJumpError: no block given (yield)>
        raise("vanilla") : RuntimeError: vanilla

## Adapters ##

Adapters for various test frameworks sit under wrong/adapters.
TODO

## Messages ##

Enhancements for error messages sit under wrong/message.
TODO

## Authors ##

* Steve Conover - <sconover@gmail.com>
* Alex Chaffee - <alex@stinky.com> - <http://alexch.github.com>

## Etc ##

Tracker project:
[http://www.pivotaltracker.com/projects/95014](http://www.pivotaltracker.com/projects/95014)

“I think it's wrong that only one company makes the game Monopoly.” -Steven Wright

"And it really doesn't matter if I'm wrong 
 I'm right where I belong"
-Fixing a Hole
