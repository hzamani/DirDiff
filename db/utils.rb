require "active_record"
require "logger"

ActiveSupport::LogSubscriber.colorize_logging=false

def connect db
  ActiveRecord::Base.establish_connection({
    :adapter => "sqlite3",
    :database => db
  })
  ActiveRecord::Base.logger = Logger.new(File.open("log/#{db}.log", "a"))
end

def create_tables db
  connect db
  ActiveRecord::Migrator.migrate('db/migrate', nil)
end
