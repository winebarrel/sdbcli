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
      'sdb.ap-southeast-2.amazonaws.com' => 'ap-southeast-2',
      'sdb.ap-northeast-1.amazonaws.com' => 'ap-northeast-1',
      'sdb.sa-east-1.amazonaws.com'      => 'sa-east-1',
    }

  class Runner
    def initialize(accessKeyId, secretAccessKey, endpoint = 'sdb.amazonaws.com')
      endpoint = region_to_endpoint(endpoint)
      @driver = Driver.new(accessKeyId, secretAccessKey, endpoint)
    end

    def endpoint
      @driver.endpoint
    end

    def endpoint=(v)
      v = region_to_endpoint(v)
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
        items = [[parsed.item_name, parsed.attrs]]
        @driver.insert(parsed.domain, items)
        1
      when :UPDATE
        @driver.update(parsed.domain, parsed.items)
        1
      when :UPDATE_WITH_EXPR
        query = "SELECT itemName FROM #{parsed.domain} #{parsed.expr}"
        items = @driver.select(query).map {|i| [i[0], parsed.attrs] }
        rownum = items.length
        @driver.update(parsed.domain, items)
        rownum
      when :MERGE
        @driver.insert(parsed.domain, parsed.items)
        1
      when :MERGE_WITH_EXPR
        query = "SELECT itemName FROM #{parsed.domain} #{parsed.expr}"
        items = @driver.select(query).map {|i| [i[0], parsed.attrs] }
        rownum = items.length
        @driver.insert(parsed.domain, items)
        rownum
      when :DELETE
        @driver.delete(parsed.domain, parsed.items)
        1
      when :DELETE_WITH_EXPR
        query = "SELECT itemName FROM #{parsed.domain} #{parsed.expr}"
        items = @driver.select(query).map {|i| [i[0], parsed.attrs] }
        rownum = items.length
        @driver.delete(parsed.domain, items)
        rownum
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
        case parsed.operand
        when :domains
          @driver.show_domains
        when :regions
          SimpleDB::REGIONS.values.sort
        else
          raise 'must not happen'
        end
      when :USE
        self.endpoint = parsed.endpoint
        nil
      when :DESCRIBE
        @driver.describe(parsed.domain)
      else
        raise 'must not happen'
      end
    end

    private

    def region_to_endpoint(region)
      if /\A[^.]+\Z/ =~ region
        region = SimpleDB::REGIONS.find {|k, v| v == region }
        raise SimpleDB::Error, 'Unknown region' unless region
        region = region.first
      end

      raise SimpleDB::Error, 'Unknown endpoint' unless SimpleDB::REGIONS[region]

      return region
    end
  end # Runner
end # SimpleDB
