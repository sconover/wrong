require "predicated/predicate"

module Predicated

  require_gem_version("json", "1.1.9")

  module JsonStructToJsonStr
    def to_json_str
      JSON.pretty_generate(to_json_struct)
    end
  end
  
  class And
    include JsonStructToJsonStr
    def to_json_struct
      {"and" => [left.to_json_struct, right.to_json_struct]}
    end
  end

  class Or
    include JsonStructToJsonStr
    def to_json_struct
      {"or" => [left.to_json_struct, right.to_json_struct]}
    end
  end

  class Not
    include JsonStructToJsonStr
    def to_json_struct
      {"not" => inner.to_json_struct}
    end
  end
  
  class Operation
    include JsonStructToJsonStr
    def to_json_struct
      [left, json_sign, right]
    end
  end

  class Equal; private; def json_sign; "==" end end
  class LessThan; private; def json_sign; "<" end end
  class GreaterThan; private; def json_sign; ">" end end
  class LessThanOrEqualTo; private; def json_sign; "<=" end end
  class GreaterThanOrEqualTo; private; def json_sign; ">=" end end
  

end