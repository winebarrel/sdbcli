require 'cgi'
require 'base64'
require 'net/https'
require 'openssl'
require 'rexml/document'

module SimpleDB
  class Error < StandardError; end

  class Client
    API_VERSION = '2009-04-15'
    SIGNATURE_VERSION = 2

    attr_accessor :endpoint

    def initialize(accessKeyId, secretAccessKey, endpoint = 'sdb.amazonaws.com', algorithm = :SHA256)
      @accessKeyId = accessKeyId
      @secretAccessKey = secretAccessKey
      @endpoint = endpoint
      @algorithm = algorithm
    end

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

    def query(action, params = {})
      params = {
        :Action           => action,
        :Version          => API_VERSION,
        :Timestamp        => Time.now.getutc.strftime('%Y-%m-%dT%H:%M:%SZ'),
        :SignatureVersion => SIGNATURE_VERSION,
        :SignatureMethod  => "Hmac#{@algorithm}",
        :AWSAccessKeyId   => @accessKeyId,
      }.merge(params)

      signature = aws_sign(params)
      params[:Signature] = signature

      Net::HTTP.version_1_2
      https = Net::HTTP.new(@endpoint, 443)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE

      doc = https.start do |w|
        req = Net::HTTP::Post.new('/',
          'Host' => @endpoint,
          'Content-Type' => 'application/x-www-form-urlencoded'
        )

        req.set_form_data(params)
        res = w.request(req)

        REXML::Document.new(res.body)
      end

      validate(doc)
      return doc
    end

    private
    def aws_sign(params)
      params = params.sort_by {|a, b| a.to_s }.map {|k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&')
      string_to_sign = "POST\n#{@endpoint}\n/\n#{params}"
      digest = OpenSSL::HMAC.digest(OpenSSL::Digest.const_get(@algorithm).new, @secretAccessKey, string_to_sign)
      Base64.encode64(digest).gsub("\n", '')
    end

    def validate(doc)
      if (error = doc.elements['//Errors/Error'])
        code = error.get_text('//Code')
        message = error.get_text('//Message')
        raise Error, "#{code}: #{message}"
      end
    end
  end # Client
end # SimpleDB
