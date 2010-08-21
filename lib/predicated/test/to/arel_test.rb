require "./test/test_helper_with_wrong"
require "./test/canonical_transform_cases"

unless RUBY_VERSION=="1.8.6"
  
require "predicated/to/arel"
include Predicated

regarding "convert a predicate to an arel where clause" do
  include CanonicalTransformCases
  
  class FakeEngine
    def connection
    end
    
    def table_exists?(name)
      true
    end
  end
  
  class FakeColumn
    attr_reader :name, :type
    def initialize(name, type)
      @name = name
      @type = type
    end
    
    def type_cast(value)
      value
    end
  end
  
  @table = Arel::Table.new(:widget, :engine => FakeEngine.new)
  Arel::Table.tables = [@table]
  @table.instance_variable_set("@columns".to_sym, [
    FakeColumn.new("a", :integer), 
    FakeColumn.new("b", :integer),
    FakeColumn.new("c", :integer)
  ])

  
  @to_expectations = {
    "simple operations" => {
      "eq" => Arel::Predicates::Equality.new(@table.attributes["a"], 3),
      "gt" => Arel::Predicates::GreaterThan.new(@table.attributes["a"], 3),
      "lt" => Arel::Predicates::LessThan.new(@table.attributes["a"], 3),
      "gte" => Arel::Predicates::GreaterThanOrEqualTo.new(@table.attributes["a"], 3),
      "lte" => Arel::Predicates::LessThanOrEqualTo.new(@table.attributes["a"], 3)
    },
    "primitive types" => {
      "false" => Arel::Predicates::Equality.new(@table.attributes["a"], false),
      "true" => Arel::Predicates::Equality.new(@table.attributes["a"], true),
      "string" => Arel::Predicates::Equality.new(@table.attributes["a"], "yyy")
    },
    "not" => {
      "simple" => Arel::Predicates::Not.new(Arel::Predicates::Equality.new(@table.attributes["a"], true))
    },
    "simple and / or" => {
      "and" => Arel::Predicates::And.new(
                 Arel::Predicates::Equality.new(@table.attributes["a"], 1), 
                 Arel::Predicates::Equality.new(@table.attributes["b"], 2)
               ),
      "or" => Arel::Predicates::Or.new(
                Arel::Predicates::Equality.new(@table.attributes["a"], 1), 
                Arel::Predicates::Equality.new(@table.attributes["b"], 2)
              )
    },
    "complex and / or" => {
      "or and" => Arel::Predicates::Or.new(
                    Arel::Predicates::And.new(
                      Arel::Predicates::Equality.new(@table.attributes["a"], 1), 
                      Arel::Predicates::Equality.new(@table.attributes["b"], 2)
                    ), 
                    Arel::Predicates::Equality.new(@table.attributes["c"], 3)
                  )
    }
  }
  
  create_canonical_tests(@to_expectations) do |predicate|
    predicate.to_arel(@table)
  end

end

end