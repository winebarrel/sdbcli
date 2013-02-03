require 'sdbcli/sdb-client'

module SimpleDB
  class Error < StandardError; end

  class Driver
    MAX_NUMBER_SUBMITTED_ITEMS = 25

    attr_accessor :iteratable

    def initialize(accessKeyId, secretAccessKey, endpoint = 'sdb.amazonaws.com')
      @client = Client.new(accessKeyId, secretAccessKey, endpoint)
      @select_expr = nil
      @next_token = nil
    end

    def endpoint
      @client.endpoint
    end

    def endpoint=(v)
      @client.endpoint = v
    end

    def timeout
      @client.timeout
    end

    def timeout=(v)
      @client.timeout = v
    end

    # domain action

    def create_domain(domain_name)
      @client.create_domain(domain_name)
    end

    def show_domains
      domains = []

      iterate(:list_domains) do |doc|
        doc.css('DomainName').each do |i|
          domains << i.content
        end
      end

      return domains
    end

    def drop_domain(domain_name)
      @client.delete_domain(domain_name)
    end

    # attr action

    def insert(domain_name, items = {})
      until (chunk = items.slice!(0, MAX_NUMBER_SUBMITTED_ITEMS)).empty?
        params = {}
        i = j = 0

        chunk.each do |item_name, attrs|
          i += 1
          params["Item.#{i}.ItemName"] = item_name

          (attrs || {}).each do |attr_name, values|
            [values].flatten.each do |v|
              j += 1
              params["Item.#{i}.Attribute.#{j}.Name"] = attr_name
              params["Item.#{i}.Attribute.#{j}.Value"] = v
              params["Item.#{i}.Attribute.#{j}.Replace"] = false
            end
          end
        end

        @client.batch_put_attributes(domain_name, params)
      end
    end

    def update(domain_name, items = {})
      until (chunk = items.slice!(0, MAX_NUMBER_SUBMITTED_ITEMS)).empty?
        params = {}
        i = j = 0

        chunk.each do |item_name, attrs|
          i += 1
          params["Item.#{i}.ItemName"] = item_name

          (attrs || {}).each do |attr_name, values|
            [values].flatten.each do |v|
              j += 1
              params["Item.#{i}.Attribute.#{j}.Name"] = attr_name
              params["Item.#{i}.Attribute.#{j}.Value"] = v
              params["Item.#{i}.Attribute.#{j}.Replace"] = true
            end
          end
        end

        @client.batch_put_attributes(domain_name, params)
      end
    end

    def get(domain_name, item_name, attr_names = [], consistent = false)
      params = {:ConsistentRead => consistent}
      attr_names.each_with_index {|name, i| params["AttributeName.#{i}"] = name }
      doc = @client.get_attributes(domain_name, item_name, params)
      attrs_to_hash(doc)
    end

    def select(expr, consistent = false, persist = false)
      params = {:SelectExpression => expr, :ConsistentRead => consistent}
      items = []

      token = iterate(:select, params) do |doc|
        doc.css('Item').map do |i|
          items << [i.at_css('Name').content, attrs_to_hash(i)]
        end
      end

      if persist
        @select_expr = expr
        @next_token = token
      end

      return items
    end

    def next_list(consistent = false)
      unless @select_expr and @next_token
        return []
      end

      params = {:SelectExpression => @select_expr, :ConsistentRead => consistent}
      items = []

      @next_token = iterate(:select, params, @next_token) do |doc|
        doc.css('Item').map do |i|
          items << [i.at_css('Name').content, attrs_to_hash(i)]
        end
      end

      return items
    end

    def delete(domain_name, items = {})
      until (chunk = items.slice!(0, MAX_NUMBER_SUBMITTED_ITEMS)).empty?
        params = {}
        i = j = 0

        chunk.each do |item_name, attrs|
          i += 1
          params["Item.#{i}.ItemName"] = item_name

          (attrs || []).each do |attr_name, values|
            [values].flatten.each do |v|
              j += 1
              params["Item.#{i}.Attribute.#{j}.Name"] = attr_name
              params["Item.#{i}.Attribute.#{j}.Value"] = v if v
            end
          end
        end

        @client.batch_delete_attributes(domain_name, params)
      end
    end

    def describe(domain_name)
      doc = @client.domain_metadata(domain_name)
      h = {}

      doc.at_css('DomainMetadataResult').children.each do |child|
        h[child.name] = child.content
      end

      return h
    end

    private

    def attrs_to_hash(node)
      h = {}

      node.css('Attribute').map do |i|
        name = i.at_css('Name').content
        value = i.at_css('Value').content

        if h[name].kind_of?(Array)
          h[name] << value
        elsif h.has_key?(name)
          h[name] = [h[name], value]
        else
          h[name] = value
        end
      end

      return h
    end

    def iterate(method, params = {}, token = :first)
      Iterator.new(@client, method, params, @iteratable, token).each do |doc|
        yield(doc)
      end
    end

    class Iterator
      def initialize(client, method, params = {}, iteratable = false, token = :first)
        @client = client
        @method = method
        @params = params.dup
        @token = token
        @iteratable = iteratable
      end

      def each
        token = nil

        while @token
          @params.update(:NextToken => @token.content) if @token != :first
          doc = @client.send(@method, @params)
          yield(doc)
          token = doc.at_css('NextToken')

          if @iteratable
            @token = token
          else
            @token = nil
          end
        end

        return token
      end
    end # Iterator
  end # Driver
end # SimpleDB
