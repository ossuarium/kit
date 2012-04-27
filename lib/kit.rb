require 'active_record'
require 'sqlite3'

require 'kit/version'
require 'kit/bit'
require 'kit/actions'

class Kit

  # Connect to a kit.
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

  # Determines and returns the kit's root directory.
  # @return [String] path to kit's root directory
  def path
    if @path.nil?
      dir = File.dirname @config_file unless @config_file.nil?
      @path = @config[:path]
      @path ||= dir
      @path = File.absolute_path( "#{dir}/#{@path}" ) unless @path =~ /^(\/|~)/
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
end