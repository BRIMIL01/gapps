$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'gapps'))
require 'gapps/connection'
require 'gapps/provisioningapi'
require 'gapps/reportingapi'
require 'gapps/emailapi'

module GApps #:nodoc:

  class GDataError < RuntimeError
    attr_accessor :code, :input, :reason
  end
end