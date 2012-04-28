require 'active_record'
require 'sqlite3'

require 'kit/version'
require 'kit/db/support'
require 'kit/db/kit'
require 'kit/db/actions'
require 'kit/bit'
require 'kit/actions'

class Kit

  # Load a kit with its configuration.
  # @param [String, Hash] config_file path to kit config file in kit root directory
  def initialize config_file
    @config_file = File.absolute_path config_file
    require "#{path}/bit"
    require "#{path}/actions"
  end

  # Load a kit with its configuration and connect to its database.
  # @param config_file (see #initialize)
  def self.open config_file
    kit = self.new config_file
    kit.db_connect kit.config[:db][:kit], KitDB
    kit.db_connect kit.config[:db][:actions], ActionsDB
    kit
  end

  # Determines and returns the kit's root directory.
  # @return [String] path to kit's root directory
  def path
    @path ||= File.dirname @config_file
  end

  # Loads settings from the config file if not already loaded.
  # @return [Hash] kit settings
  def config
    @config ||= YAML.load( File.read @config_file )
  end

  # Dynamically define actions handled by KitSupportDB
  [:create, :destroy, :connect].each do |action|
    define_method "db_#{action}".to_sym do |database, *args|
      db_action action, database, *args
    end
  end

  private

  def db_action action, database, *args
    if database == :all
      config[:db].each { |c| KitSupportDB.send action, c, *args }
    else
      KitSupportDB.send action, config[:db][database], *args
    end
  end

end