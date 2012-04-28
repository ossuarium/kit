require 'kit'

describe Kit::Bit do

  CONFIG_FILE = File.expand_path '../../test_kit/config.yml', __FILE__

  before :all do
    Kit.new(CONFIG_FILE).db_create
  end

  after :all do
    Kit.new(CONFIG_FILE).db_destroy
  end

  before :each do
    @kit = Kit.open CONFIG_FILE
  end

  describe ".new" do
  end
end