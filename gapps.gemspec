$:.push File.expand_path("../lib", __FILE__)
require 'gapps/version'

Gem::Specification.new do |s|
  s.name = %q{gapps}
  s.version = GApps::VERSION
  s.date = %q{2011-02-25}
  
  s.authors = ["Brian Miller"]
  
  s.summary = "Client Google Provisioning API"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.files = ["Rakefile"] + Dir.glob("lib/**/*")

  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}

  #s.add_runtime_dependency 'httparty', '>= 0.6.0'
  
  s.add_development_dependency 'rspec', '~> 2.3.0'

  if RUBY_VERSION >= "1.9"
    s.add_development_dependency 'ruby-debug19'
  else
    s.add_development_dependency 'ruby-debug' 
  end
end