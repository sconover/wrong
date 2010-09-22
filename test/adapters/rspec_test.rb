require "./test/test_helper"

describe "testing rspec" do
  it "works" do

    require "wrong/adapters/rspec" # if we don't require this in here, then it interferes with minitest
    
    # I would use
    #    out, err = capturing(:stdout, :stderr) do
    # but minitest does its own arcane stream munging and it's not working

    out = StringIO.new
    err = StringIO.new
    Spec::Runner.use(Spec::Runner::Options.new(out, err))

    module RSpecWrapper
      include Spec::DSL::Main
      describe "inside rspec land" do
        it "works" do
          sky = "blue"
          assert { sky == "green" }
        end
      end
    end

    Spec::Runner.options.parse_format("nested")
    Spec::Runner.options.run_examples

    assert(err.string.index(<<-RSPEC) == 0, "make sure the rspec formatter was used")
inside rspec land
  works (FAILED - 1)

1)
'inside rspec land works' FAILED
    RSPEC

    failures = Spec::Runner.options.reporter.instance_variable_get(:@failures) # todo: use my own reporter?
    assert !failures.empty?
    exception = failures.first.exception
    assert(exception.is_a?(Spec::Expectations::ExpectationNotMetError))
    assert(exception.message == "Expected (sky == \"green\"), but \"blue\" is not equal to \"green\"\n    sky is \"blue\"\n")
  end
end
