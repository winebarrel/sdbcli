require 'sdbcli/sdb-client'
require 'sdbcli/sdb-resultset'

module SimpleDB
  class Error < StandardError; end

  class Driver
    def initialize(accessKeyId, secretAccessKey, endpoint = 'sdb.amazonaws.com', algorithm = :SHA256)
      @client = Client.new(accessKeyId, secretAccessKey, endpoint, algorithm)
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
        doc.get_elements('//DomainName').each do |i|
          domains << i.text
        end
      end

      return domains
    end

    def drop_domain(domain_name)
      @client.delete_domain(domain_name)
    end

    # attr action

    def insert(domain_name, item_name, attrs = {}, consistent = false)
      insert_or_update0(domain_name, item_name, attrs, consistent, false)
    end

    def update(domain_name, item_name, attrs = {}, consistent = false)
      insert_or_update0(domain_name, item_name, attrs, consistent, true)
    end

    def insert_or_update0(domain_name, item_name, attrs, consistent, replace)
      params = {:ConsistentRead => consistent}
      i = 0

      attrs.each do |attr|
        name, values = attr

        [values].flatten.each do |v|
          i += 1
          params["Attribute.#{i}.Name"] = name
          params["Attribute.#{i}.Value"] = v
          params["Attribute.#{i}.Replace"] = replace
        end
      end

      doc = @client.put_attributes(domain_name, item_name, params)
    end
    private :insert_or_update0

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
        doc.get_elements('//Item').map do |i|
          items << [i.get_text('Name').to_s, attrs_to_hash(doc)]
        end
      end

      ResultSet.new(items)
    end

    def delete(domain_name, item_name, attrs = [], consistent = false)
      params = {:ConsistentRead => consistent}
      i = 0

      attrs.each do |attr|
        name, values = attr

        [values].flatten.each do |v|
          i += 1
          params["Attribute.#{i}.Name"] = name
          params["Attribute.#{i}.Value"] = v if v
        end
      end

      doc = @client.delete_attributes(domain_name, item_name, params)
    end

    private

    def attrs_to_hash(doc)
      h = {}

      doc.get_elements('//Attribute').map do |i|
        name = i.get_text('Name').to_s
        value = i.get_text('Value').to_s

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
      Iterator.new(@client, method, params).each do |doc|
        yield(doc)
      end
    end

    class Iterator
      def initialize(client, method, params = {})
        @client = client
        @method = method
        @params = params.dup
        @token = :first
      end

      def each
        while @token
          @params.update(:NextToken => @token.to_s) if @token != :first
          doc = @client.send(@method, @params)
          yield(doc)
          @token = doc.get_text('//NextToken')
        end
      end
    end # Iterator
  end # Driver
end # SimpleDB
