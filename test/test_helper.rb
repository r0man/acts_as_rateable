require 'rubygems'
require 'active_support'
require 'active_support/test_case'

ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..'

require 'test/unit'
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))

class Article < ActiveRecord::Base
  acts_as_rateable :range => (1..5)
end

class User < ActiveRecord::Base
end

def database_adapter

  require 'sqlite3'

  adapter = ENV['DB']
  adapter ||=

    begin
      require 'rubygems'
      require 'sqlite'
      'sqlite'
    rescue MissingSourceFile

      begin
        require 'sqlite3'
        'sqlite3'
      rescue MissingSourceFile
      end

    end

  raise "No Database Adapter selected. Pass the DB= option to pick one, or install Sqlite or Sqlite3." unless adapter

  adapter

end

def load_schema

  config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
  ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")

  ActiveRecord::Base.establish_connection(config[database_adapter])

  load(File.dirname(__FILE__) + "/schema.rb")
  require File.dirname(__FILE__) + '/../rails/init.rb'

end
