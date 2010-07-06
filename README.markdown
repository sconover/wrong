## Abstract ##

Wrong provides a general assert method that takes a predicate block.  Assertion failure messages are rich in detail.

Wrong is alpha-quality - I'd very much appreciate feedback and bug reports.

It's an offshoot of predicated.
http://github.com/sconover/predicated

Inspired by assert { 2.0 }
http://assert2.rubyforge.org/

## Usage ##

Wrong provides a simple assert method:

	require "wrong"
	
	include Wrong::Assert
	
	assert{1==1} 
	 ==> nil
	
	assert{2==1}
	 ==> Wrong::Assert::AssertionFailedError: 2 is not equal to 1

And a companion, 'deny':

	deny{'abc'.include?('bc')}
	 ==> Wrong::Assert::AssertionFailedError: 'abc' includes 'bc'

There's a convenience method for catching errors:

	assert{ catch_raise{raise "boom!"}.message == "boom!" }
	 ==> nil

## Etc ##

Tracker project:
http://www.pivotaltracker.com/projects/95014

“I think it's wrong that only one company makes the game Monopoly.” -Steven Wright

"And it really doesn't matter if I'm wrong 
 I'm right where I belong"
-Fixing a Hole