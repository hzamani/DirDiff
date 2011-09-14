require 'active_record'
require './models/directory'
require './models/file'

def connect(name)
  ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => "db/#{name}.db"})
end
