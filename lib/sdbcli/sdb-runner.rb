require 'sdbcli/sdb-driver'
require 'sdbcli/sdb-parser.tab'

# XXX:
class Array
  def to_s
    self.map {|i| i.to_s }
  end

  def to_i
    self.map {|i| i.to_i }
  end

  def to_f
    self.map {|i| i.to_f }
  end

  def sum
    self.inject {|r, i| r + i }
  end

  def avg
    self.sum / self.length
  end
end

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
    class Rownum
      def initialize(rownum)
        @rownum = rownum
      end

      def to_i
        @rownum
      end
    end

    attr_reader :driver

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

    def timeout
      @driver.timeout
    end

    def timeout=(v)
      @driver.timeout = v
    end

    def iteratable
      @driver.iteratable
    end

    def iteratable=(v)
      @driver.iteratable = v
    end

    def region
      REGIONS[endpoint]
    end

    def execute(query, inline = true, consistent = false)
      parsed = Parser.parse(query)
      command = parsed.class.name.split('::').last.to_sym

      case command
      when :GET
        item = @driver.get(parsed.domain, parsed.item_name, parsed.attr_names, consistent)

        if inline
          def item.to_yaml_style; :inline; end
        end

        item
      when :INSERT
        rownum = parsed.items.length
        @driver.insert(parsed.domain, parsed.items)
        Rownum.new(rownum)
      when :UPDATE
        rownum = parsed.items.length
        @driver.update(parsed.domain, parsed.items)
        Rownum.new(rownum)
      when :UPDATE_WITH_EXPR
        query = "SELECT itemName FROM #{parsed.domain} #{parsed.expr}"
        items = @driver.select(query, consistent).map {|i| [i[0], parsed.attrs] }
        rownum = items.length
        @driver.update(parsed.domain, items)
        Rownum.new(rownum)
      when :MERGE
        rownum = parsed.items.length
        @driver.insert(parsed.domain, parsed.items)
        Rownum.new(rownum)
      when :MERGE_WITH_EXPR
        query = "SELECT itemName FROM #{parsed.domain} #{parsed.expr}"
        items = @driver.select(query, consistent).map {|i| [i[0], parsed.attrs] }
        rownum = items.length
        @driver.insert(parsed.domain, items)
        Rownum.new(rownum)
      when :DELETE
        rownum = parsed.items.length
        @driver.delete(parsed.domain, parsed.items)
        Rownum.new(rownum)
      when :DELETE_WITH_EXPR
        query = "SELECT itemName FROM #{parsed.domain} #{parsed.expr}"
        items = @driver.select(query, consistent).map {|i| [i[0], parsed.attrs] }
        rownum = items.length
        @driver.delete(parsed.domain, items)
        Rownum.new(rownum)
      when :SELECT, :NEXT, :CURRENT
        items = case command
                when :SELECT
                  @driver.select(parsed.query, consistent, true)
                when :NEXT
                  @driver.next_list(consistent)
                when :CURRENT
                  @driver.current_list(consistent)
                else
                  raise 'must not happen'
                end

        def items.method_missing(method_name)
          case method_name.to_s
          when /itemName/i
            self.map {|i| i[0] }
          else
            self.map {|i| i[1][method_name.to_s] }
          end
        end

        items.each do |item|
          def item.method_missing(method_name)
            case method_name.to_s
            when /itemName/i
              self[0]
            else
              self[1][method_name.to_s]
            end
          end
        end

        if parsed.ruby
          begin
            items = items.instance_eval(parsed.ruby.strip)
          rescue SyntaxError => e
            raise e.message
          end
        end

        if inline and items.kind_of?(Array)
          items.each do |item|
            if item.kind_of?(Array)
              def item.to_yaml_style; :inline; end
            end
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
