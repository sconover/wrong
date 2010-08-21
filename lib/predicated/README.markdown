## Abstract ##

Predicated is a simple predicate model for Ruby.  It provides useful predicate transformations and operations.

Tracker project:
[http://www.pivotaltracker.com/projects/95014](http://www.pivotaltracker.com/projects/95014)

## Transformations ##

- From:
  - json
  - xml
  - url part, ex: "!(a=1&b=2|c=3)"
  - callable objects (lambdas/procs, and therefore blocks) - ruby 1.8.x only
  - ruby code - ruby 1.8.x only
- To:
  - json
  - xml
  - sql where clause via [arel](http://github.com/rails/arel)
  - [solr](http://lucene.apache.org/solr/) query string
  - english sentence, ex: "'a' is not equal to 'b'"

## Usage ##

Note: The test suite acts as a comprehensive usage guide.


Evaluate a predicate:
    
    require "predicated/evaluate"
    include Predicated
            
    Predicate { Eq(1, 2) }.evaluate == false
    Predicate { Lt(1, 2) }.evaluate == true
    Predicate { Or(Lt(1, 2),Eq(1, 2)) }.evaluate == true
    
    x = 1
    Predicate { Lt(x, 2) }.evaluate == true


Parse a predicate from part of a url and then turn it into a sql where clause:
    
    require "predicated/from/url_part"
    require "predicated/to/arel"
        
    predicate = Predicated::Predicate.from_url_part("(color=red|color=green)&size=large")
    
    predicate.inspect == 
      "And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))" 
    
    predicate.to_arel(Table(:shirt)).to_sql == 
      %{(("shirt"."color" = 'red' OR "shirt"."color" = 'green') AND "shirt"."size" = 'large')} 
  

Parse a predicate from json and then turn it into a solr query string:
    
    require "predicated/from/json"
    require "predicated/to/solr"
        
    predicate = Predicated::Predicate.from_json_str(%{
      {"and":[{"or":[["color","==","red"],["color","==","green"]]},["size","==","large"]]}
    })
        
    predicate.inspect == "And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))" 
        
    predicate.to_solr == "((color:red OR color:green) AND size:large)" 

  
From json:
    
    require "predicated/from/json"
        
    Predicated::Predicate.from_json_str(%{
      {"and":[
        {"or":[
          ["color","==","red"],
          ["color","==","green"]
        ]},
        ["size","==","large"]
      ]}
    }).inspect == "And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))" 


From xml:
    
    require "predicated/from/xml"
        
    Predicated::Predicate.from_xml(%{
      <and>
        <or>
          <equal><left>color</left><right>red</right></equal>
          <equal><left>color</left><right>green</right></equal>
        </or>
        <equal><left>size</left><right>large</right></equal>
      </and>
    }).inspect == "And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))" 


From url part:
    
    require "predicated/from/url_part"
        
    Predicated::Predicate.from_url_part("(color=red|color=green)&size=large").inspect ==
      "And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))" 


From callable object:
    
    require "predicated/from/callable_object"
        
    Predicated::Predicate.from_callable_object{('color'=='red' || 'color'=='green') && 'size'=='large'}.inspect ==
      "And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))" 


From ruby code string:
      
    require "predicated/from/ruby_code_string"
            
    Predicated::Predicate.from_ruby_code_string("('color'=='red' || 'color'=='green') && 'size'=='large'").inspect ==
      "And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))" 
  
  
To json:
      
    require "predicated/to/json"
    include Predicated
            
    Predicate{And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))}.to_json_str ==
    %{
      {"and":[
        {"or":[
          ["color","==","red"],
          ["color","==","green"]
        ]},
        ["size","==","large"]
      ]}
    }
  
  
To xml:
      
    require "predicated/to/xml"
    include Predicated
            
    Predicate{And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))}.to_xml ==
    %{
      <and>
        <or>
          <equal><left>color</left><right>red</right></equal>
          <equal><left>color</left><right>green</right></equal>
        </or>
        <equal><left>size</left><right>large</right></equal>
      </and>      
    }
  
  
To arel (sql where clause):
      
    require "predicated/to/arel"
    include Predicated
            
    Predicate{And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))}.to_arel(Table(:shirt)).to_sql ==
      %{(("shirt"."color" = 'red' OR "shirt"."color" = 'green') AND "shirt"."size" = 'large')}
  
  
To solr query string:
      
    require "predicated/to/solr"
    include Predicated
            
    Predicate{And(Or(Eq('color','red'),Eq('color','green')),Eq('size','large'))}.to_solr ==
      "((color:red OR color:green) AND size:large)"
  
  
To sentence:
      
    require "predicated/to/sentence"
    include Predicated
        
    Predicate{ And(Eq("a",1),Eq("b",2)) }.to_sentence == 
      "'a' is equal to 1 and 'b' is equal to 2"
    
    Predicate{ Gt("a",1) }.to_negative_sentence == 
      "'a' is not greater than 1" 


## Testing Notes ##

Right now this project makes use of Wrong for assertions.  Wrong uses this project.  It's kind of neat in an eat-your-own-dogfood sense, but it's possible that this will be problematic over time (particularly when changes in this project cause assertions to behave differently - if even temporarily).

A middle ground is to make "from ruby string" and "from callable object" use minitest asserts, since these are the "interesting" parts of Predicated relied on by Wrong.