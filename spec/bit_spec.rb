require 'kit'

describe Kit::Bit do

  before :all do
    @config = File.expand_path '../config.yml', __FILE__
  end

  after :all do
    config = YAML.load( File.read @config )
    db = File.expand_path "../#{config[:kit][:db][:path]}", __FILE__
    File.unlink db if File.exists? db
  end

  describe ".new" do

    it "makes a bit" do
      kit = Kit.open @config
      bit = Kit::Bit.new name: "test"
      bit.save
    end

  end
end