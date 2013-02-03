require 'cgi'
require 'base64'
require 'net/https'
require 'openssl'
require 'nokogiri'
require 'stringio'
require 'zlib'

module SimpleDB
  class Error < StandardError; end

  class Client
    API_VERSION = '2009-04-15'
    SIGNATURE_VERSION = 2
    SIGNATURE_ALGORITHM = :SHA256

    attr_accessor :endpoint
    attr_accessor :timeout

    def initialize(accessKeyId, secretAccessKey, endpoint = 'sdb.amazonaws.com')
      @accessKeyId = accessKeyId
      @secretAccessKey = secretAccessKey
      @endpoint = endpoint
      @timeout = 60
    end

    # domain action

    def create_domain(domain_name, params = {})
      params = params.merge(:DomainName => domain_name)
      query('CreateDomain', params)
    end

    def list_domains(params = {})
      query('ListDomains', params)
    end

    def delete_domain(domain_name, params = {})
      params = params.merge(:DomainName => domain_name)
      query('DeleteDomain', params)
    end

    # attr action

    def put_attributes(domain_name, item_name, params = {})
      params = params.merge(:DomainName => domain_name, :ItemName => item_name)
      query('PutAttributes', params)
    end

    def get_attributes(domain_name, item_name, params = {})
      params = params.merge(:DomainName => domain_name, :ItemName => item_name)
      query('GetAttributes', params)
    end

    def select(params = {})
      query('Select', params)
    end

    def delete_attributes(domain_name, item_name, params = {})
      params = params.merge(:DomainName => domain_name, :ItemName => item_name)
      query('DeleteAttributes', params)
    end

    # batch attr action

    def batch_put_attributes(domain_name, params = {})
      params = params.merge(:DomainName => domain_name)
      query('BatchPutAttributes', params)
    end

    def batch_delete_attributes(domain_name, params = {})
      params = params.merge(:DomainName => domain_name)
      query('BatchDeleteAttributes', params)
    end

    def domain_metadata(domain_name)
      query('DomainMetadata', :DomainName => domain_name)
    end

    private

    def query(action, params = {})
      params = {
        :Action           => action,
        :Version          => API_VERSION,
        :Timestamp        => Time.now.getutc.strftime('%Y-%m-%dT%H:%M:%SZ'),
        :SignatureVersion => SIGNATURE_VERSION,
        :SignatureMethod  => "Hmac#{SIGNATURE_ALGORITHM}",
        :AWSAccessKeyId   => @accessKeyId,
      }.merge(params)

      signature = aws_sign(params)
      params[:Signature] = signature

      Net::HTTP.version_1_2
      https = Net::HTTP.new(@endpoint, 443)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      https.open_timeout = @timeout
      https.read_timeout = @timeout

      doc = https.start do |w|
        req = Net::HTTP::Post.new('/',
          'Host' => @endpoint,
          'Content-Type' => 'application/x-www-form-urlencoded',
          'Accept-Encoding' => 'gzip'
        )

        req.set_form_data(params)
        res = w.request(req)
        body = nil

        if res['Content-Encoding'] == 'gzip'
          StringIO.open(res.body, 'rb') do |f|
            body = Zlib::GzipReader.wrap(f).read
          end
        else
          body = res.bod
        end

        Nokogiri::XML(body)
      end

      validate(doc)
      return doc
    end

    private
    def aws_sign(params)
      params = params.sort_by {|a, b| a.to_s }.map {|k, v| "#{escape(k)}=#{escape(v)}" }.join('&')
      string_to_sign = "POST\n#{@endpoint}\n/\n#{params}"
      digest = OpenSSL::HMAC.digest(OpenSSL::Digest.const_get(SIGNATURE_ALGORITHM).new, @secretAccessKey, string_to_sign)
      Base64.encode64(digest).gsub("\n", '')
    end

    def validate(doc)
      if (error = doc.at_css('Errors Error'))
        code = error.at_css('Code').content
        message = error.at_css('Message').content
        raise Error, "#{code}: #{message}"
      end
    end

    def escape(str)
      CGI.escape(str.to_s).gsub('+', '%20')
    end
  end # Client
end # SimpleDB
