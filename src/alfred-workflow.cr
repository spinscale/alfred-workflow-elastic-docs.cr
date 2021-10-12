require "./parser"
require "./docs_client"

parser = Parser.new
client = DocsClient.new

query = parser.parse ARGV[0]
response = client.query query
puts response
