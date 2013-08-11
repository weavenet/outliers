require 'rubygems'
require 'bundler/setup'

require 'outliers'

Dir[File.expand_path(File.join(File.dirname(__FILE__),'helpers', '*.rb'))].each do |f|
  require f
end

def credentials
  YAML.load(fixture_file 'credentials1.yml')
end

def stub_logger
  Outliers.logger stub 'test'
  Outliers.logger.stub :debug => true, :info => true, :warn => true
end
         
RSpec.configure do |config|
  config.include Fixtures
end
