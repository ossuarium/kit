module KitDBSupport

  def self.create! config
    case config[:adapter]
    when 'sqlite3'
      db_file = config[:database]
      raise RuntimeError, "Database file #{db_file} exists." if File.exists? db_file
      SQLite3::Database.new config[:database]
    else
      raise RuntimeError, "Creating database with adapter #{config[:adapter]} not supported."
    end
  end

  def self.create *args
    begin
      create! *args
    rescue RuntimeError, /^Database file .+ exists.$/
    end
  end

  def self.destroy! config
    case config[:adapter]
    when 'sqlite3'
      db_file = config[:database]
      raise RuntimeError, "Database file #{db_file} does not exist." unless File.exists? db_file
      File.unlink db_file
    else
      raise RuntimeError, "Destroying database with adapter #{config[:adapter]} not supported."
    end
  end

  def self.destroy *args
    begin
      destroy! *args
    rescue RuntimeError, /^Database file .+ does not exist.$/
    end
  end

  # Establishes an ActiveRecord::Base connection.
  # @param [Hash] db_config settings for ActiveRecord::Base
  # @param [Class] db_class ActiveRecord::Base subclass to receive connection
  def self.connect config
    ActiveRecord::Base.establish_connection config
  end
end