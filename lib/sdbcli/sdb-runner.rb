require 'sdbcli/sdb-driver'
require 'sdbcli/sdb-parser.tab'

# XXX:
class Array
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

  def as_row
    row = self.dup

    def row.method_missing(method_name, *args, &block)
      case method_name.to_s
      when /itemName/i
        self[0]
      when /=\Z/
        self[1][method_name.to_s.sub(/=\Z/, '')] = (args.length > 2) ? args : args[0]
      else
        self[1][method_name.to_s]
      end
    end

    return row
  end

  def as_row!
    row = self

    def row.method_missing(method_name, *args, &block)
      case method_name.to_s
      when /itemName/i
        self[0]
      when /=\Z/
        self[1][method_name.to_s.sub(/=\Z/, '')] = (args.length > 2) ? args : args[0]
      else
        self[1][method_name.to_s]
      end
    end

    return row
  end

  def as_rows
    rows = self.dup

    def rows.method_missing(method_name, *args, &block)
      case method_name.to_s
      when /itemName/i
        self.map {|i| i[0] }
      when /=\Z/
        self.each do |i|
          i[1][method_name.to_s.sub(/=\Z/, '')] = (args.length > 2) ? args : args[0]
        end
        self
      else
        self.map {|i| i[1][method_name.to_s] }
      end
    end

    return rows
  end

  def as_rows!
    rows = self

    def rows.method_missing(method_name, *args, &block)
      case method_name.to_s
      when /itemName/i
        self.map {|i| i[0] }
      when /=\Z/
        self.each do |i|
          i[1][method_name.to_s.sub(/=\Z/, '')] = (args.length > 2) ? args : args[0]
        end
        self
      else
        self.map {|i| i[1][method_name.to_s] }
      end
    end

    return rows
  end

  def inline
    obj = self.dup
    def obj.to_yaml_style; :inline; end
    return obj
  end

  def inline!
    obj = self
    def obj.to_yaml_style; :inline; end
    return obj
  end
end

class Hash
  def inline
    obj = self.dup
    def obj.to_yaml_style; :inline; end
    return obj
  end

  def inline!
    obj = self
    def obj.to_yaml_style; :inline; end
    return obj
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
        item.inline! if inline
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
      when :SELECT, :NEXT, :CURRENT, :PREV, :PAGE
        items = case command
                when :SELECT
                  @driver.select(parsed.query, consistent, true)
                when :NEXT
                  @driver.next_list(consistent)
                when :CURRENT
                  @driver.current_list(consistent)
                when :PREV
                  @driver.prev_list(consistent)
                when :PAGE
                  parsed.page ? @driver.page_to(parsed.page, consistent) : @driver.current_page
                else
                  raise 'must not happen'
                end

        unless items.kind_of?(Integer)
          items.as_rows!

          items.each do |item|
            item.as_row!
          end

          def items.group_by(name, &block)
            item_h = {}

            self.each do |item|
              key = item[1][name.to_s]

              unless item_h[key]
                item_list = [].as_rows
                item_h[key] = item_list
              end

              item_h[key] << item
            end

            if block
              old_item_h = item_h
              item_h = {}

              old_item_h.each do |key, item_list|
                if block.arity == 2
                  new_item_list = block.call(item_list, key)
                else
                  new_item_list = block.call(item_list)
                end

                item_h[key] = new_item_list
              end
            end

            item_h
          end
        end

        if parsed.script
          begin
            case parsed.script_type
            when :ruby
              items = items.instance_eval(parsed.script.strip)
            when :shell
              items = IO.popen(parsed.script.strip, "r+") do |f|
                f.puts(items.kind_of?(Array) ? items.map {|i| i.to_s }.join("\n") : items.to_s)
                f.close_write
                f.read
              end
            else
              raise 'must not happen'
            end
          rescue Exception => e
            raise SimpleDB::Error, e.message
          end
        end

        if inline and items.kind_of?(Array)
          items.each do |item|
            item.inline! if item.kind_of?(Array)
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
      when :RUBY
        eval(parsed.script.strip)
      when :EXEC
        `#{parsed.script.strip}`
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
