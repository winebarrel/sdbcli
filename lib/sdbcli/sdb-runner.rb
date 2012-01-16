require 'sdbcli/sdb-driver'
require 'sdbcli/sdb-parser.tab'

module SimpleDB
  class Error < StandardError; end

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

    def execute(query)
      parsed = Parser.parse(query)
      command = parsed.class.name.split('::').last.to_sym

      case command
      when :GET
        @driver.get(parsed.domain, parsed.item_name, parsed.attr_names)
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
        @driver.select(parsed.query)
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
