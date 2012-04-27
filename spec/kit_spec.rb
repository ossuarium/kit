require 'kit'

describe Kit do

  before :all do
    @kit_path = File.expand_path '../../test_kit', __FILE__
    @config = File.expand_path '../config.yml', __FILE__
    @default = YAML.load( File.read "#{@kit_path}/config.yml" )
    @custom = YAML.load( File.read @config )
  end

  describe ".new" do

    it "determines the correct path to the kit when given" do
      kit = Kit.new @config
      kit.path.should == @kit_path
    end

    it "determines the correct path to the kit when not explicitly given" do
      kit = Kit.new "#{@kit_path}/config.yml"
      kit.path.should == @kit_path
    end

    it "merges the default and custom config files" do
      kit = Kit.new @config
      kit.instance_variable_get(:@config).should == @default.merge(@custom)
    end

    it "accecpts a hash for a config and merges it with the default config" do
      @custom[:path] = File.absolute_path "../#{@custom[:path]}", __FILE__
      kit = Kit.new @custom
      kit.instance_variable_get(:@config).should == @default.merge(@custom)
    end

    it "connects to the kit database"

  end
end