class Parser

  @@CURRENT_VERSION = "8.0"

  @@PRODUCTS = {
    # beats
    "b" => "Libbeat",
    "mb"=> "Metricbeat",
    "pb" => "Packetbeat",
    "wb" => "Winlogbeat",
    "fb"=> "Filebeat",
    "hb" => "Heartbeat",
    "fb" => "Functionbeat",
    "jb" => "Journalbeat",
    # elasticsearch
    "e" => "Elasticsearch",
    "es"=> "Elasticsearch",
    # logstash
    "l" => "Logstash",
    "ls"=> "Logstash",
    # kibana
    "k"=> "Kibana",
    # cloud
    "c"=> "Elastic Cloud",
    "ece" => "ECE",
    # stack
    "s"=> "Elastic Stack",
    # clients
    "cs"=> "Clients",
    # infrastructure
    "i"=> "Infrastructure",
    # swiftype
    "sw" => "Swiftype",
    # apm
    "a" => "APM",
    "apm" => "APM",
    # Elastic common schema
    "ecs" => "Elastic Common Schema (ecs)"
  }

  def parse(input : String)
    product = @@PRODUCTS.find { |k, v|
      input.starts_with?(k + " ")
    }
    if !product.nil?
      input = input[product[0].size + 1, input.size]
      product = product[1]
    end

    regex = Regex.new "^[0-9]\.[0-9x]([0-9*]?)(\.[0-9](\-[0-9a-z]*)?)?"
    if match = input.match regex
      version = match[0]
      input = input[version.size + 1, input.size]
    else
      version = @@CURRENT_VERSION
    end

    { "query" => input, "version" => version, "product" => product }
  end

end
