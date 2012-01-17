require 'sdbcli/sdb-driver'
require 'sdbcli/sdb-parser.tab'

module SimpleDB
  class Error < StandardError; end

    REGIONS = {
      'sdb.amazonaws.com'                => 'us-east-1',
      'sdb.us-west-1.amazonaws.com'      => 'us-west-1',
      'sdb.us-west-2.amazonaws.com'      => 'us-west-2',
      'sdb.eu-west-1.amazonaws.com'      => 'eu-west-1',
      'sdb.ap-southeast-1.amazonaws.com' => 'ap-southeast-1',
      'sdb.ap-northeast-1.amazonaws.com' => 'ap-northeast-1',
      'sdb.sa-east-1.amazonaws.com'      => 'sa-east-1',
    }

  class Runner
    def initialize(accessKeyId, secretAccessKey, endpoint = 'sdb.amazonaws.com')
      @driver = Driver.new(accessKeyId, secretAccessKey, endpoint)
    end

    def endpoint
      @driver.endpoint
    end

    def endpoint=(v)
      @driver.endpoint = v
    end

    def region
      REGIONS[endpoint]
    end

    def execute(query, inline = true)
      parsed = Parser.parse(query)
      command = parsed.class.name.split('::').last.to_sym

      case command
      when :GET
        item = @driver.get(parsed.domain, parsed.item_name, parsed.attr_names)

        if inline
          def item.to_yaml_style; :inline; end
        end

        item
      when :INSERT
        @driver.insert(parsed.domain, parsed.item_name, parsed.attrs)
        nil
      when :UPDATE
        @driver.update(parsed.domain, parsed.items)
        nil
      when :DELETE
        @driver.delete(parsed.domain, parsed.items)
        nil
      when :SELECT
        items = @driver.select(parsed.query)

        if inline
          items.each do |item|
            def item.to_yaml_style; :inline; end
          end
        end

        items
      when :CREATE
        @driver.create_domain(parsed.domain)
        nil
      when :DROP
        @driver.drop_domain(parsed.domain)
        nil
      when :SHOW
        @driver.show_domains
      else
        raise 'must not happen'
      end
    end
  end # Runner
end # SimpleDB
