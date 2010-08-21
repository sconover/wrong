module CanonicalIntegrationCases

  def fixtures
    [
      {:id => 101, :eye_color => "red", :height => "short", :age => "old", :cats => 0},
      {:id => 102, :eye_color => "blue", :height => "tall", :age => "old", :cats => 2},
      {:id => 103, :eye_color => "green", :height => "short", :age => "young", :cats => 3}
    ]
  end

  
  module ClassMethods
    
    def create_canonical_tests(attrs)
      tests = {
        "simple eq" => { Predicate{ Eq(attrs[:id], 101) } => [101] },
        "string eq" => { Predicate{ Eq(attrs[:eye_color],"blue") } => [102] },
        "simple gt" => { Predicate{ Gt(attrs[:cats], 1) } => [102, 103] },
        "simple lt" => { Predicate{ Lt(attrs[:cats], 3) } => [101, 102] },
        "simple gte" => { Predicate{ Gte(attrs[:cats], 2) } => [102, 103] },
        "simple lte" => { Predicate{ Lte(attrs[:cats], 2) } => [101, 102] },
        "simple not" => { Predicate{ Not(Eq(attrs[:eye_color],"blue")) } => [101, 103] },
        "simple and / or" => {
          Predicate{And(Eq(attrs[:height],"tall"),Eq(attrs[:age],"old"))} => [102],
          Predicate{And(Eq(attrs[:height],"short"),Eq(attrs[:age],"old"))} => [101],
          Predicate{Or(Eq(attrs[:height],"short"),Eq(attrs[:age],"young")) } => [101, 103]
        },
        "complex and / or" => {
          
          Predicate{ 
            Or(
              And(
                Eq(attrs[:height],"short"),
                Eq(attrs[:age],"young")
              ),
              Eq(attrs[:eye_color],"red")
            ) 
          } => [101, 103],
          
          Predicate{ 
            Or(
              And(
                Eq(attrs[:height],"tall"),
                Eq(attrs[:age],"old")
              ),
              Eq(attrs[:eye_color],"green")
            ) 
          } => [102, 103]
        }
      }
  
      tests.each do |test_name, cases|
        test test_name do
          cases.each do |predicate, expected_ids|
            actual_ids = yield(predicate).sort
            assert { actual_ids == expected_ids }
          end
        end
      end
    end
  end
  
  def self.included(other)
    other.extend(ClassMethods)
  end
end