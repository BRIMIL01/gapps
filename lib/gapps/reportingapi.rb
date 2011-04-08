module GApps
  class ReportingApi
    @@google_host = 'www.google.com'
    @@google_port = 443

    # http://code.google.com/apis/apps/reporting/google_apps_reporting_api.html

    def initialize(mail, passwd, proxy=nil, proxy_port=nil, proxy_user=nil, proxy_passwd=nil)
      @domain = mail.split('@')[1]
      conn = Connection.new(@@google_host, @@google_port, mail, passwd, proxy, proxy_port, proxy_user, proxy_passwd)
      @connection = conn
      return @connection
    end

    def get_report(name, date, page=1)
      msg = GReportMessage.new
      msg.add_parameter("type", "Report")
      @connection.check_token
      msg.add_parameter("token", @connection.token)
      msg.add_parameter("domain", @domain)
      msg.add_parameter("date", date.to_date.to_s)
      msg.add_parameter("page", page)
      msg.add_parameter("reportType", "daily")
      msg.add_parameter("reportName", name)

      response = @connection.request({:method => 'POST', :path => "/hosted/services/v1.0/reports/ReportingData" }, nil, msg.to_s, {'Content-Type'=>'text/xml'}, false)
    end
  end

  class GReportMessage < REXML::Document #:nodoc:
    def initialize
      super '<?xml version="1.0" encoding="UTF-8"?>' 
      self.add_element "rest", {"xmlns" => "google:accounts:rest:protocol", "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance"}
    end

    def add_parameter(name, value)
      self.elements["rest"].add_element(name)
      self.elements["rest"].elements[name].text = value
    end
  end
end