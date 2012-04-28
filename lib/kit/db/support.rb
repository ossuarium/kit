module KitSupportDB

  def self.create config
    case config[:adapter]
    when 'sqlite3'
      SQLite3::Database.new config[:database]
    else
      raise RuntimeError, "Creating database with adapter #{config[:adapter]} not supported"
    end
  end

  def self.destroy config
    case config[:adapter]
    when 'sqlite3'
      File.unlink config[:database]
    else
      raise RuntimeError, "Destroying database with adapter #{config[:adapter]} not supported"
    end
  end

  # Establishes an ActiveRecord::Base connection.
  # @param [Hash] db_config settings for ActiveRecord::Base
  # @param [Class] db_class ActiveRecord::Base subclass to receive connection
  def self.connect config, ar_class
    ar_class.establish_connection config
  end
end