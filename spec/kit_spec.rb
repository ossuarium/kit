require 'kit'

describe Kit do

  before :all do
    @kit_path = File.expand_path '../../test_kit', __FILE__
    @config = File.expand_path '../config.yml', __FILE__
    @default = YAML.load( File.read "#{@kit_path}/config.yml" )
    @custom = YAML.load( File.read @config )
  end

  describe ".new" do

    before :each do
      Kit.any_instance.stub :db_connect
    end

    context "when the path to the kit explicitly given" do

      it "determines the correct path to the kit" do
        kit = Kit.new @config
        kit.path.should == @kit_path
      end
    end

    context "when the path to the kit not explicitly given" do

      it "determines the correct path to the kit" do
        kit = Kit.new "#{@kit_path}/config.yml"
        kit.path.should == @kit_path
      end
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
  end

  describe ".open" do

    it "creates a new kit and opens a database connections" do
      Kit.any_instance.should_receive :db_connect
      Kit.open @config
    end
  end

  describe ".db_connect" do

    before :each do
      @kit = Kit.new @config
    end

    context "when the database adapter is sqlite3" do

      before :all do
        @db = File.expand_path "../#{@custom[:kit][:db][:path]}", __FILE__
      end

      after :all do
        File.unlink @db if File.exists? @db
      end

      it "creates the database files" do
        SQLite3::Database.should_receive(:new).with(@db)
        @kit.db_connect @kit.config[:db]
      end

      it "makes active record establish a connection" do
        ActiveRecord::Base.should_receive(:establish_connection).with(adapter: 'sqlite3', database: @db)
        @kit.db_connect @kit.config[:db]
      end

    end
  end
end