require 'lib/connection'
require 'lib/provisioningapi'
require 'lib/reportingapi'
require 'lib/emailapi'

module GApps #:nodoc:
	
	class GDataError < RuntimeError
		attr_accessor :code, :input, :reason
	end
end