require "./test/test_helper_with_wrong"
require "./test_integration/canonical_integration_cases"

require "predicated/predicate"
require "predicated/to/arel"
include Predicated

require "sqlite3-ruby"
require "active_record"


def get_from_db_using_predicate(predicate)
  Table(:widget).where(predicate.to_arel(Table(:widget))).select.
    collect{|r|r.tuple}.
    collect{|d|d.first}
end

regarding "predicates run against a real db" do
  include CanonicalIntegrationCases
  
  
  before do
    unless @created
      db_file = "/tmp/sqlite_db"
      FileUtils.rm_f(db_file)
      @db = SQLite3::Database.new(db_file)
      ActiveRecord::Base.establish_connection(:adapter => "sqlite3-ruby", :database  => db_file)
      @db.execute(%{
        create table widget (
          id INTEGER PRIMARY KEY, 
          eye_color VARCHAR(25), 
          height VARCHAR(25), 
          age VARCHAR(25), 
          cats NUMERIC);
      })
      
      self.fixtures.each do |row|
        @db.execute("insert into widget values (#{row[:id]}, '#{row[:eye_color]}', '#{row[:height]}', '#{row[:age]}', #{row[:cats]})")
      end
    end
    @created = true    
  end
  
  create_canonical_tests(
    :id => "id", 
    :eye_color => "eye_color", 
    :height => "height",
    :age => "age",
    :cats => "cats") do |predicate|
      get_from_db_using_predicate(predicate)
  end
end