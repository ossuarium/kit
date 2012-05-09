require 'active_record'
require 'sqlite3'

require 'kit/version'
require 'kit/db_support'
require 'kit/bit'

class Kit

  # Load a kit with its configuration.
  # @param [String, Hash] config_file path to kit config file in kit root directory
  def initialize config_file
    @config_file = File.absolute_path config_file
    require "#{path}/bit"
  end

  # Load a kit with its configuration and connect to its database.
  # @param config_file (see #initialize)
  def self.open config_file
    kit = self.new config_file
    kit.db_connect
    kit
  end

  # Determines and returns the kit's root directory.
  # @return [String] path to kit's root directory
  def path
    @path ||= File.dirname @config_file
  end

  # Loads settings from the config file (only loads from file on first call).
  # @return [Hash] kit settings
  def config
    @config ||= YAML.load(File.read @config_file)
  end

  # Dynamically define actions handled by KitSupportDB
  [:create, :destroy, :connect, :migrate, :migrate_to].each do |action|
    define_method "db_#{action}".to_sym do |*args|
      db_action action, *args
    end
  end

  # Some actions have bang versions.
  [:create, :destroy].each do |action|
    define_method "db_#{action}!".to_sym do |*args|
      db_action action, *args
    end
  end

  private

  # Passes db_* method calls to KitSupportDB.
  def db_action action, *args
    if [:migrate, :migrate_to].include? action
      KitDBSupport.send action, path, *args
    else
      KitDBSupport.send action, config[:db], *args
    end
  end

end