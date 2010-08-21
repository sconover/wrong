require "./test/test_helper_with_wrong"

require "predicated/to/arel"
require "sqlite3-ruby"
require "active_record"
require "fileutils"

regarding "prove out examples used in the README" do
  
  before do
    unless @created
      db_file = "/tmp/sqlite_db"
      FileUtils.rm_f(db_file)
      @db = SQLite3::Database.new(db_file)
      ActiveRecord::Base.establish_connection(:adapter => "sqlite3-ruby", :database  => db_file)
      @db.execute(%{
        create table shirt (
          id INTEGER PRIMARY KEY, 
          color VARCHAR(25), 
          size VARCHAR(25)
        );
      })      
    end
    @created = true    
  end  
  
  
  test "Evaluate a predicate" do
    
    require "predicated/evaluate"
    extend Predicated #include Predicated
            
    assert{
    Predicate { Eq(1, 2) }.evaluate == false
    }
    assert{
    Predicate { Lt(1, 2) }.evaluate == true
    }
    assert{
    Predicate { Or(Lt(1, 2),Eq(1, 2)) }.evaluate == true
    }
    
    assert{
    x = 1
    Predicate { Lt(x, 2) }.evaluate == true
    }
  end


  test "Parse a predicate from part of a url and then turn it into a sql where clause" do
    
    require "predicated/from/url_part"
    require "predicated/to/arel"
        
    predicate = Predicated::Predicate.from_url_part("(color=red|color=green)&size=large")
    
    assert{ 
    predicate.inspect == 
      "And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))" 
    }
    
    assert{ 
    predicate.to_arel(Table(:shirt)).to_sql == 
      %{(("shirt"."color" = 'red' OR "shirt"."color" = 'green') AND "shirt"."size" = 'large')} 
    }
  end
  

  test "Parse a predicate from json and then turn it into a solr query string" do
    
    require "predicated/from/json"
    require "predicated/to/solr"
        
    predicate = Predicated::Predicate.from_json_str(%{
      {"and":[{"or":[["color","==","red"],["color","==","green"]]},["size","==","large"]]}
    })
        
    assert{ 
    predicate.inspect == "And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))" 
    }
        
    assert{ 
    predicate.to_solr == "((color:red OR color:green) AND size:large)" 
    }
  end

  
  test "From json" do
    
    require "predicated/from/json"
        
    assert{ 
    Predicated::Predicate.from_json_str(%{
      {"and":[
        {"or":[
          ["color","==","red"],
          ["color","==","green"]
        ]},
        ["size","==","large"]
      ]}
    }).inspect == "And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))" 
    }
  end


  test "From xml" do
    
    require "predicated/from/xml"
        
    assert{ 
    Predicated::Predicate.from_xml(%{
      <and>
        <or>
          <equal><left>color</left><right>red</right></equal>
          <equal><left>color</left><right>green</right></equal>
        </or>
        <equal><left>size</left><right>large</right></equal>
      </and>
    }).inspect == "And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))" 
    }
  end


  test "From url part" do
    
    require "predicated/from/url_part"
        
    assert{ 
    Predicated::Predicate.from_url_part("(color=red|color=green)&size=large").inspect ==
      "And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))" 
    }
  end


  test "From callable object" do
    
    require "predicated/from/callable_object"
        
    assert{ 
    Predicated::Predicate.from_callable_object{('color'=='red' || 'color'=='green') && 'size'=='large'}.inspect ==
      "And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))" 
    }
  end


  test "From ruby code string" do
      
    require "predicated/from/ruby_code_string"
            
    assert{ 
    Predicated::Predicate.from_ruby_code_string("('color'=='red' || 'color'=='green') && 'size'=='large'").inspect ==
      "And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))" 
    }
  end
  
  
  test "To json" do
      
    require "predicated/to/json"
    extend Predicated #include Predicated
            
    assert{ 
    Predicate{And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))}.to_json_str.gsub(/\s/, "") ==
    %{
      {"and":[
        {"or":[
          ["color","==","red"],
          ["color","==","green"]
        ]},
        ["size","==","large"]
      ]}
    }.gsub(/\s/, "")
    }
  end
  
  
  test "To xml" do
      
    require "predicated/to/xml"
    extend Predicated #include Predicated
            
    assert{ 
    Predicate{And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))}.to_xml.gsub(/\s/, "") ==
    %{
      <and>
        <or>
          <equal><left>color</left><right>red</right></equal>
          <equal><left>color</left><right>green</right></equal>
        </or>
        <equal><left>size</left><right>large</right></equal>
      </and>      
    }.gsub(/\s/, "")
    }
  end
  
  
  test "To arel (sql where clause)" do
      
    require "predicated/to/arel"
    extend Predicated #include Predicated
            
    assert{ 
    Predicate{And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))}.to_arel(Table(:shirt)).to_sql ==
      %{(("shirt"."color" = 'red' OR "shirt"."color" = 'green') AND "shirt"."size" = 'large')}
    }
  end
  
  
  test "To solr query string" do
      
    require "predicated/to/solr"
    extend Predicated #include Predicated
            
    assert{ 
    Predicate{And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))}.to_solr ==
      "((color:red OR color:green) AND size:large)"
    }
  end
  
  
  test "To sentence" do
      
    require "predicated/to/sentence"
    extend Predicated #include Predicated
        
    assert{
    Predicate{ And(Eq("a",1),Eq("b",2)) }.to_sentence == 
      "'a' is equal to 1 and 'b' is equal to 2"
    }
    
    assert { 
    Predicate{ Gt("a",1) }.to_negative_sentence == 
      "'a' is not greater than 1" 
    }    
  end
  
  xtest "format and puts me" do
    lines = File.read(__FILE__).split("\n")
    lines =
      lines.reject do |line|
        line.include?("assert") || line =~ /^[ ]*\}[ ]*$/ || line =~ /^[ ]*end[ ]*$/
      end
    str = lines.join("\n")
    
    puts str.
      gsub("  test \"", "").
      gsub("\" do", ":").
      gsub("extend Predicated #include Predicated", "include Predicated").
      gsub(%{.gsub(/\\s/, "")}, "")
  end
  
end