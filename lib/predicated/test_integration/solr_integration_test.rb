require "./test/test_helper_with_wrong"
require "./test_integration/canonical_integration_cases"
require "net/http"
require "open-uri"

require "predicated/predicate"
require "predicated/to/solr"
include Predicated

#download and unpack solr
#place (overwrite) schema.xml in the solr conf directory
#start solr (java -jar start.jar)

def get_from_solr_using_predicate(predicate)
  eval(get_from_solr("/solr/select?q=#{URI.escape(predicate.to_solr)}&wt=ruby"))
end

def get_from_solr(path)
  open("http://localhost:8983#{path}").read
end

def post_to_solr(body)
  request = Net::HTTP::Post.new("/solr/update", {'Content-Type' =>'text/xml'})
  request.body = body
  response = Net::HTTP.new("localhost", 8983).start {|http| http.request(request) }
  raise "Response #{response.code}\n#{response.body}" unless response.code=="200"
end

regarding "solr is running properly" do
  test "solr schema is the one from this project" do
    assert{ get_from_solr("/solr/admin/file/?file=schema.xml") == File.read("test_integration/schema.xml") }
  end
end


regarding "predicates run against real solr" do
  include CanonicalIntegrationCases
  
  before do
    unless @posted
      post_to_solr("<delete><query>*:*</query></delete>")
      post_to_solr("<commit/>")
      
      docs_str = 
        self.fixtures.collect do |row|
          %{
          <doc>
            <field name="id">#{row[:id]}</field>
            <field name="eye_color_s">#{row[:eye_color]}</field>
            <field name="height_s">#{row[:height]}</field>
            <field name="age_s">#{row[:age]}</field>
            <field name="cats_i">#{row[:cats]}</field>
          </doc>  
          }
        end.join("\n")
      
      post_to_solr("<add>#{docs_str}</add>")
      post_to_solr("<commit/>")
    end
    @posted = true    
  end
  
  create_canonical_tests(
    :id => "id", 
    :eye_color => "eye_color_s", 
    :height => "height_s",
    :age => "age_s",
    :cats => "cats_i") do |predicate|
      get_from_solr_using_predicate(predicate)["response"]["docs"].collect{|d|d["id"].to_i}
  end
end