require "spec"
require "webmock"
require "../src/docs_client"

describe DocsClient do

  client = DocsClient.new

  json = %Q({
    "meta": { "page": { "total_results": 2 } },
    "results": [
      {
        "title": {"raw": "Open" },
        "product_name": { "raw": "Curator" },
        "url": { "raw": "http://localhost:8000/guide/en/elasticsearch/client/curator/4.0/open.html" }
      },
      {
        "title": {"raw": "Open Examples" },
        "product_name": { "raw": "Logstash" },
        "url": { "raw": "http://localhost:8000/guide/en/guide/en/logstash/foo/examples.html#ex_open" }
      }
    ]
  })

  Spec.before_each &->WebMock.reset

  it "should query" do
    WebMock.stub(:post, "https://host-nm1h2z.api.swiftype.com/api/as/v1/engines/elastic-en-us/search")
      .with(body: "{\"query\":\"match query\",\"page\":{\"size\":10},\"search_fields\":{\"title\":{\"weight\":3},\"body\":{}},\"result_fields\":{\"title\":{\"raw\":{}},\"url\":{\"raw\":{}},\"product_name\":{\"raw\":{}}},\"filters\":{\"all\":[{\"website_area\":[\"documentation\"]},{\"product_version\":\"7.15\"},{\"product_name\":\"Elasticsearch\"}]}}", headers: {"Authorization" => "Bearer search-yq8eq2orbgnmq1jjjfw4hocv"})
      .to_return(status: 200, body: json)

    resp = JSON.parse client.query({ "query" => "match query", "version" : "7.15", "product" => "Elasticsearch"})
    resp["items"].size.should eq 2
  end

  it "should return empty search response" do
    WebMock.stub(:post, "https://host-nm1h2z.api.swiftype.com/api/as/v1/engines/elastic-en-us/search").
      to_return(status: 200, body: %Q({"meta": { "page": { "total_results": 0 } }}))

    resp = JSON.parse client.query({ "query" => "match query", "version" : "7.15", "product" => "Elasticsearch"})
    resp.size.should eq 1
    resp["items"][0]["title"].as_s.should eq "No results found"
  end
end
