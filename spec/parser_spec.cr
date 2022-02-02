require "spec"
require "../src/parser"

describe Parser do

  parser = Parser.new

  it "should parse" do
    parser.parse("foo").should eq({ "query" => "foo", "product" => nil, "version" => "7.17" })
  end

  it "should parse products" do
    parser.parse("a foo bar").should eq({ "query" => "foo bar", "product" => "APM", "version" => "7.17" })
    parser.parse("e foo").should eq({ "query" => "foo", "product" => "Elasticsearch", "version" => "7.17" })
  end

  it "should parse products and versions" do
    parser.parse("a 2.2 foo bar").should eq({ "query" => "foo bar", "product" => "APM", "version" => "2.2" })
    parser.parse("e 7.13 match query").should eq({ "query" => "match query", "product" => "Elasticsearch", "version" => "7.13" })
  end
end
