require 'active_record'
require 'sqlite3'

require 'kit/version'
require 'kit/bit'
require 'kit/actions'

class Kit

  # Load a kit.
  # @param [String, Hash] custom_config path to kit config file or hash of kit settings
  def initialize custom_config
    case custom_config
    when String
      @config_file = File.absolute_path custom_config
      config
    when Hash
      config custom_config
    else
      raise RuntimeError, 'No configuration given.'
    end
  end

  # Load a kit and connect to its database.
  # @param custom_config (see #initialize)
  def self.open custom_config
    kit = self.new custom_config
    kit.db_connect kit.config[:db]
    return kit
  end

  # Determines and returns the kit's root directory.
  # @return [String] path to kit's root directory
  def path
    if @path.nil?
      dir = File.dirname @config_file unless @config_file.nil?
      @path = @config[:path]
      @path ||= dir
      @path = File.absolute_path( "#{dir}/#{@path}" ) if ( @path =~ /^[\/~]/ ).nil?
    end
    @path
  end

  # Returns the kit settings.
  # @param [Hash] custom_config used if no config file specified
  # @return [Hash] kit level settings
  def config custom_config = nil
    @config ||= custom_config

    if @config.nil? || custom_config
      @config = YAML.load( File.read @config_file ) unless @config_file.nil?
      @config = YAML.load( File.read "#{path}/config.yml" ).merge(@config)
    end

    @config[:kit]
  end

  # Creates Active Record connection to database adapter.
  # @param [Hash] db_config settings for ActiveRecord::Base
  def db_connect db_config
    case db_config[:adapter]
    when :sqlite3

      db_path = db_config[:path]
      if ( db_path =~ /^(\/|~)/ ).nil?
        db_path = "#{File.dirname @config_file}/#{db_path}" unless @config_file.nil?
        db_path = File.absolute_path( db_path )
      end

      SQLite3::Database.new db_path unless File.exists? db_path
      ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: db_path
    else
      raise LoadError, 'No such database adapter'
    end
  end
end