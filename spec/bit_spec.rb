require 'kit'

describe Kit::Bit do

  before :all do
    @config_file = File.expand_path '../../test_kit/config.yml', __FILE__
    Kit.new(@config_file).db_create.db_connect.db_migrate
  end

  after :all do
    Kit.new(@config_file).db_destroy
  end

  before :each do
    Kit.open @config_file
  end
end