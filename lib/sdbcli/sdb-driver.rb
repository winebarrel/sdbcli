require 'sdbcli/sdb-client'

module SimpleDB
  class Error < StandardError; end

  class Driver
    attr_accessor :iteratable

    def initialize(accessKeyId, secretAccessKey, endpoint = 'sdb.amazonaws.com')
      @client = Client.new(accessKeyId, secretAccessKey, endpoint)
    end

    def endpoint
      @client.endpoint
    end

    def endpoint=(v)
      @client.endpoint = v
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

    def insert(domain_name, item_name, attrs = {}, consistent = false)
      params = {:ConsistentRead => consistent}
      i = 0

      attrs.each do |name, values|
        [values].flatten.each do |v|
          i += 1
          params["Attribute.#{i}.Name"] = name
          params["Attribute.#{i}.Value"] = v
          params["Attribute.#{i}.Replace"] = false
        end
      end

      @client.put_attributes(domain_name, item_name, params)
    end

    def update(domain_name, items = {}, consistent = false)
      params = {:ConsistentRead => consistent}
      i = j = 0

      items.each do |item_name, attrs|
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

    def get(domain_name, item_name, attr_names = [], consistent = false)
      params = {:ConsistentRead => consistent}
      attr_names.each_with_index {|name, i| params["AttributeName.#{i}"] = name }
      doc = @client.get_attributes(domain_name, item_name, params)
      attrs_to_hash(doc)
    end

    def select(expr, consistent = false)
      params = {:SelectExpression => expr, :ConsistentRead => consistent}
      items = []

      iterate(:select, params) do |doc|
        doc.css('Item').map do |i|
          items << [i.at_css('Name').content, attrs_to_hash(i)]
        end
      end

      return items
    end

    def delete(domain_name, items = {}, consistent = false)
      params = {:ConsistentRead => consistent}
      i = j = 0

      items.each do |item_name, attrs|
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

    def iterate(method, params = {})
      Iterator.new(@client, method, params, @iteratable).each do |doc|
        yield(doc)
      end
    end

    class Iterator
      def initialize(client, method, params = {}, iteratable = false)
        @client = client
        @method = method
        @params = params.dup
        @token = :first
        @iteratable = iteratable
      end

      def each
        while @token
          @params.update(:NextToken => @token.content) if @token != :first
          doc = @client.send(@method, @params)
          yield(doc)

          if @iteratable
            @token = doc.at_css('NextToken')
          else
            @token = nil
          end
        end
      end
    end # Iterator
  end # Driver
end # SimpleDB
