require 'net/https'
require 'cgi'
require 'rexml/document'

include REXML

module GApps #:nodoc:
  class Connection
    attr_reader :http_connection
    attr_reader :token
    attr_reader :token_ttl
    attr_reader :mail
    attr_reader :passwd

    # Establishes SSL connection to Google host
    def initialize(host, port, mail, passwd, proxy=nil, proxy_port=nil, proxy_user=nil, proxy_passwd=nil)	
      conn = Net::HTTP.new(host, port, proxy, proxy_port, proxy_user, proxy_passwd)
      conn.use_ssl = true
      # #conn.enable_post_connection_check=  true
      # #conn.verify_mode = OpenSSL::SSL::VERIFY_PEER
      conn.verify_mode = OpenSSL::SSL::VERIFY_NONE 
      # # uncomment the previous line at your own risk : the certificate won't be verified !
      # store = OpenSSL::X509::Store.new
      # store.set_default_paths
      # conn.cert_store = store
      @mail = mail
      @passwd = passwd
      @http_connection = conn
      @token_ttl = Time.now
      @token = login(@mail, @passwd)
      @headers = {'Content-Type'=>'application/atom+xml', 'Authorization'=> 'GoogleLogin auth='+@token}
    end

    # Performs the http request and returns the http response
    def perform(method, path, body=nil, header=nil)
      req = Net::HTTPGenericRequest.new(method, !body.nil?, true, path)
      req['Content-Type'] = header['Content-Type'] if header['Content-Type']
      req['Authorization'] = header['Authorization'] if header['Authorization']
      req['Content-length'] = body.length.to_s if body
      resp = @http_connection.request(req, body)
      return resp
    end

    # Perfoms a REST request based on the action hash (cf setup_actions)
    # ex : request (:user_retrieve, 'jsmith') sends a http GET www.google.com/a/feeds/domain/user/2.0/jsmith	
    # returns  REXML Document
    def request(action, value=nil, message=nil, header=nil, parse_response=true)
      #param value : value to be concatenated to action path ex: GET host/path/value
      check_token
      hd = header || @headers
      method = action[:method]
      value = '' if !value
      path = action[:path]+value
      begin
        response = perform(method, path, message, hd)
        return parse_response(response) if parse_response
        return response
      rescue GDataError => e
        STDERR.puts "Error occurred ", e
        return nil
      rescue Exception => e
        STDERR.puts "Exception occurred ", e
        return nil
      end
    end

    def check_token
      if ((Time.now - @token_ttl) > 86400) 
        @token = login(@mail, @passwd)
        @token_ttl = Time.now
        @headers = {'Content-Type'=>'application/atom+xml', 'Authorization'=> 'GoogleLogin auth='+@token}
      end
    end

    # Sends credentials and returns an authentication token
    def login(mail, passwd)
      request_body = '&Email='+CGI.escape(mail)+'&Passwd='+CGI.escape(passwd)+'&accountType=HOSTED&service=apps'
      res = request({:method => 'POST', :path => '/accounts/ClientLogin' }, nil, request_body, {'Content-Type'=>'application/x-www-form-urlencoded'})
      return /^Auth=(.+)$/.match(res.to_s)[1]
      # res.to_s needed, because res.class is REXML::Document
    end

    # parses xml response for an API error tag. If an error, constructs and raises a GDataError.
    def parse_response(response)
      if response.code == "503"
        gdata_error = GDataError.new
        gdata_error.code = "503"
        gdata_error.input = "-"
        gdata_error.reason = "Apps API invoked too rapidly."
        msg = "error code : "+gdata_error.code+", invalid input : "+gdata_error.input+", reason : "+gdata_error.reason
        raise gdata_error, msg
      end

      begin
        xml = Document.new(response.body)
      rescue Exception => e
        STDERR.puts "Error processing response: ", e
        return nil
      end

      error = xml.elements["AppsForYourDomainErrors/error"]
      if error
        gdata_error = GDataError.new
        gdata_error.code = error.attributes["errorCode"]
        gdata_error.input = error.attributes["invalidInput"]
        gdata_error.reason = error.attributes["reason"]
        msg = "error code : "+gdata_error.code+", invalid input : "+gdata_error.input+", reason : "+gdata_error.reason
        raise gdata_error, msg
      end
      return xml
    end
  end
end