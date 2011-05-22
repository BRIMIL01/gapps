module GApps
  class EmailApi
    @@google_host = 'apps-apis.google.com'
    @@google_port = 443

    # http://code.google.com/apis/apps/email_settings/developers_guide_protocol.html

    def initialize(mail, passwd, proxy=nil, proxy_port=nil, proxy_user=nil, proxy_passwd=nil)
      domain = mail.split('@')[1]
      @action = setup_actions(domain)
      conn = Connection.new(@@google_host, @@google_port, mail, passwd, proxy, proxy_port, proxy_user, proxy_passwd)
      @connection = conn
      return @connection
    end

    # Creates a label in Google Mail
    # 	params :
    # 		username
    #			label
    # 	ex : 	
    #			myapps = EmailApi.new('root@mydomain.com','PaSsWoRd')
    #			myapps.create_label("someone", 'status updates')
    #
    def create_label(username, lbl)
      msg = GEmailMessage.new
      msg.add_property("label", lbl)
      response = @connection.request(@action[:label], "/#{username}/label", msg.to_s)
      return !response.nil?
    end

    # Creates a mail filter in Google Mail
    # 	params :
    # 		username
    #			criteria can include the following keys:
    # 		'from', 'to', 'subject', 'hasTheWord', 'doesNotHaveTheWord', 'hasAttachment'
    #  		actions can include the following keys:
    # 		'label', 'shouldMarkAsRead', 'shouldArchive'
    # 	ex : 	
    #			myapps = EmailApi.new('root@mydomain.com','PaSsWoRd')
    #			myapps.create_filter("someone", {'from' => 'someone@somewhere.com'}, {'label' => 'ignore'})
    #
    def create_filter(username, criteria={}, actions={})
      unless criteria.size == 0 and actions.size == 0
        msg = GEmailMessage.new
        allowedCriteria = ['from', 'to', 'subject', 'hasTheWord', 'doesNotHaveTheWord', 'hasAttachment']
        allowedActions = ['label', 'shouldMarkAsRead', 'shouldArchive']
        criteria.each do |k,v|
          if allowedCriteria.include?(k)	 
            v.tr!('[]()$&#*', '')
            if k == 'hasAttachment'
              msg.add_property(k, v.to_s)
            else
              msg.add_property(k, v)
            end
          end
        end
        actions.each do |k,v|
          if allowedActions.include?(k)	 
            v.tr!('[]()$&#*', '')
            if ['shouldMarkAsRead', 'shouldArchive'].include?(k)
              msg.add_property(k, v.to_s)
            else
              msg.add_property(k, v)
            end
          end
        end
        response = @connection.request(@action[:filter], "/#{username}/filter", msg.to_s)
        return !response.nil?
      end
      return false
    end

    def add_sendas(username, name, address, reply_to=nil, make_default=nil)
      msg = GEmailMessage.new
      msg.add_property('name', name)
      msg.add_property('address', address)
      msg.add_property('replyTo', reply_to) unless reply_to.nil?
      msg.add_property('makeDefault', make_default.to_s) unless make_default.nil?
      response = @connection.request(@action[:sendas], "/#{username}/sendas", msg.to_s)
      return !response.nil?
    end

    def enable_webclips(username)
      msg = GEmailMessage.new
      msg.add_property('enable', 'true')
      response = @connection.request(@action[:webclip], "/#{username}/webclip", msg.to_s)
      return !response.nil?
    end

    def disable_webclips(username)
      msg = GEmailMessage.new
      msg.add_property('enable', 'false')
      response = @connection.request(@action[:webclip], "/#{username}/webclip", msg.to_s)
      return !response.nil?
    end


    # Accepts "KEEP", "ARCHIVE" or "DELETE" as action values
    def enable_forwarding(username, forward_to, action="ARCHIVE")
      msg = GEmailMessage.new
      msg.add_property('enable', "true")
      msg.add_property('forwardTo', forward_to)
      msg.add_property('action', action)
      response = @connection.request(@action[:forwarding], "/#{username}/forwarding", msg.to_s)
      return !response.nil?
    end

    def disable_forwarding(username)
      msg = GEmailMessage.new
      msg.add_property('enable', "false")
      response = @connection.request(@action[:forwarding], "/#{username}/forwarding", msg.to_s)
      return !response.nil?
    end

    # Accepts "KEEP", "ARCHIVE" or "DELETE" as action values
    def enable_pop(username, all_mail=true, action="KEEP")
      msg = GEmailMessage.new
      msg.add_property('enable', "true")
      enable_for = (all_mail) ? "ALL_MAIL" : "MAIL_FROM_NOW_ON"
      msg.add_property('enableFor', "enable_for")
      msg.add_property('action', action)
      response = @connection.request(@action[:pop], "/#{username}/pop", msg.to_s)
      return !response.nil?
    end

    def disable_pop(username)
      msg = GEmailMessage.new
      msg.add_property('enable', "false")
      response = @connection.request(@action[:pop], "/#{username}/pop", msg.to_s)
      return !response.nil?
    end

    def enable_imap(username)
      msg = GEmailMessage.new
      msg.add_property('enable', "true")
      response = @connection.request(@action[:imap], "/#{username}/imap", msg.to_s)
      return !response.nil?
    end

    def disable_imap(username)
      msg = GEmailMessage.new
      msg.add_property('enable', "false")
      response = @connection.request(@action[:imap], "/#{username}/imap", msg.to_s)
      return !response.nil?
    end

    def enable_vacation_responder(username, subject, message, contacts_only=true)
      msg = GEmailMessage.new
      msg.add_property('enable', "true")
      msg.add_property('subject', subject)
      msg.add_property('message', message)
      msg.add_property('contactsOnly', contacts_only.to_s)
      response = @connection.request(@action[:vacation], "/#{username}/vacation", msg.to_s)
      return !response.nil?
    end

    def disable_vacation_responder(username)
      msg = GEmailMessage.new
      msg.add_property('enable', "false")
      response = @connection.request(@action[:vacation], "/#{username}/vacation", msg.to_s)
      return !response.nil?
    end

    def set_signature(username, signature)
      msg = GEmailMessage.new
      msg.add_property('signature', signature)
      response = @connection.request(@action[:signature], "/#{username}/signature", msg.to_s)
      return !response.nil?
    end

    # see http://code.google.com/apis/apps/email_settings/developers_guide_protocol.html#GA_email_language_tags for a list of languages
    def set_language(username, language)
      msg = GEmailMessage.new
      msg.add_property('language', language)
      response = @connection.request(@action[:language], "/#{username}/language", msg.to_s)	
      return !response.nil?
    end

    # general settings are pageSize, shortcuts, arrows, snippets and unicode
    def update_general_settings(username, settings={})
      unless settings.size == 0
        settings.each do |k,v|
          if ['shortcuts', 'arrows', 'snippets', 'unicode'].include?(k)
            msg.add_property(k, v.to_s)
          else
            msg.add_property(k, v)
          end
        end
        response = @connection.request(@action[:general], "/#{username}/general", msg.to_s)
        return !response.nil?
      end
      return false
    end

    # private methods
    private #:nodoc:

    # Associates methods, http verbs and URL for REST access
    def setup_actions(domain)
      path = "/a/feeds/emailsettings/2.0/#{domain}"

      action = Hash.new
      action[:label] = { :method => 'POST', :path => path }
      action[:filter] = { :method => 'POST', :path => path }
      action[:sendas] = { :method => 'POST', :path => path } 
      action[:webclip] = { :method => 'PUT', :path => path }
      action[:forwarding] = { :method => 'PUT', :path => path }
      action[:pop] = { :method => 'PUT', :path => path }
      action[:imap] = { :method => 'PUT', :path => path }
      action[:vacation] = { :method => 'PUT', :path => path }
      action[:signature] = { :method => 'PUT', :path => path }
      action[:language] = { :method => 'PUT', :path => path }
      action[:general] = { :method => 'PUT', :path => path }

      # special action "next" for linked feed results. :path will be affected with URL received in a link tag.
      action[:next] = {:method => 'GET', :path =>nil }
      return action  	
    end
  end

  class GEmailMessage < REXML::Document #:nodoc:
    def initialize
      super '<?xml version="1.0" encoding="UTF-8"?>' 
      self.add_element "atom:entry", {"xmlns:apps" => "http://schemas.google.com/apps/2006", "xmlns:atom" => "http://www.w3.org/2005/Atom"}
    end

    def add_property(name, value)
      self.elements["atom:entry"].add_element("apps:property", { "name" => name, "value" => value }) 
    end
  end
end