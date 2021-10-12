require "http/client"
require "json"

class DocsClient

  @@URL = "https://host-nm1h2z.api.swiftype.com/api/as/v1/engines/elastic-en-us/search"

  @@ICONS = {
    "beats"         => "/logos/beats.png",
    "cloud"         => "/logos/cloud.png",
    "elasticsearch" => "/logos/elasticsearch.png",
    "logstash"      => "/logos/logstash.png",
    "kibana"        => "/logos/kibana.png",
    "xpack"         => "/logos/xpack.png",
    "watcher"       => "/logos/xpack.png",
    "marvel"        => "/logos/xpack.png",
    "shield"        => "/logos/xpack.png"
  }

  def query(query : Hash(String, String | Nil))
    body = JSON.parse %Q({ "query": "#{query["query"]}", "page":{ "size": 10 },"search_fields":{"title":{"weight":3}, "body":{}},"result_fields":{"title":{"raw":{}},"url":{"raw":{}},"product_name":{"raw":{}}},"filters":{"all":[{"website_area":["documentation"]},{"product_version":"#{query["version"]}"}]}})

    if query.has_key?("product")
      body["filters"]["all"].as_a << JSON.parse %Q({"product_name":"#{query["product"]}"})
    end

    headers = HTTP::Headers {
      "Authorization" => "Bearer search-yq8eq2orbgnmq1jjjfw4hocv",
      # without the content type an obscure error message is returned
      "Content-Type" => "application/json",
    }

    response = HTTP::Client.post(@@URL, headers: headers, body: body.to_json)

    response_json = JSON.parse response.body

    if response_json["meta"]["page"]["total_results"].as_i == 0
      JSON.build do |json|
        json.object do
          json.field "items" do
            json.array do
              json.object do
                json.field "title", "No results found"
                json.field "icon" do
                  json.object do
                    json.field "path", "#{Dir.current}/icon.png"
                  end
                end
              end
            end
          end
        end
      end
    else
      JSON.build do |json|
        json.object do
          json.field "items" do
            json.array do
              response_json["results"].as_a.map do |hit|
                json.object do
                  json.field "title", hit["title"]["raw"].as_s
                  json.field "subtitle", hit["product_name"]["raw"].as_s
                  json.field "arg", hit["url"]["raw"].as_s
                  product_name = hit["product_name"]["raw"].as_s.downcase
                  product = @@ICONS.has_key?(product_name) ? @@ICONS[product_name] : @@ICONS["elasticsearch"]
                  icon = Dir.current + product
                  json.field "icon" do
                    json.object do
                      json.field "path", icon
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

end
