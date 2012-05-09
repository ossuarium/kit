module KitDBSupport

  # Create a database.
  # @raise RuntimeError This will raise an exception if databse exists.
  # @param [Hash] config ActiveRecord::Base database configuration
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

  # (see #create!)
  def self.create *args
    begin
      create! *args
    rescue RuntimeError, /^Database file .+ exists.$/
    end
  end

  # Destory a database.
  # @raise RuntimeError This will raise an exception if databse does not exist.
  # @param (see create!)
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

  # (see #destroy)
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

  # Migrate up or down a given number of migrations.
  # @param [String] path location of migration files
  # @param [Symbol] direction
  # @param [Integer] steps
  def self.migrate path, direction = nil, steps = 1
    if direction.nil?
      ActiveRecord::Migrator.migrate(path, ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    else
      ActiveRecord::Migrator.send direction, path, steps
    end
  end

  # Migrate to a specfic migration.
  # @param path (see #migrate)
  # @param [Integer] version the migration number
  def self.migrate_to path, version
    ActiveRecord::Migrator.migrate(path, version)
  end
end