require 'sdbcli/sdb-client'

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

      iterate(:list_domains, :NextToken => 100) do |doc|
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

    def get(domain_name, item_name, attr_name = [], consistent = false)
      params = {}
      attr_name.each_with_index {|name, i| params["AttributeName.#{i}"] = name }
      params[:ConsistentRead] = consistent

      doc = @client.get_attributes(domain_name, item_name, params)
      row = {}

      doc.get_elements('//Attribute').map do |i|
        name = i.get_text('Name').to_s
        value = i.get_text('Value').to_s

        if row[name].kind_of?(Array)
          row[name] << value
        elsif row.has_key?(name)
          row[name] = [row[name], value]
        else
          row[name] = value
        end
      end

      return row
    end

    private

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
          @params.update(:NextToken => @token) if @token != :first
          doc = @client.send(@method, @params)
          yield(doc)
          @token = doc.get_text('//NextToken').to_s
        end
      end
    end # Iterator
  end # Driver
end # SimpleDB
