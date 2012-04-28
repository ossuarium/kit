require 'kit'

describe KitSupportDB do

  before :all do
    @config = {}
    @config[:sqlite3] = { adapter: 'sqlite3', database: 'spec_db.sqlite3' }
  end

  after :each do
    sqlite3 = 'spec_db.sqlite3'
    File.unlink sqlite3 if File.exists? sqlite3
  end


  describe "create" do

    it "raises error if adapter not supported" do
      expect { KitSupportDB::create( :adapter => 'bad_adapter' ) }.should raise_error RuntimeError
    end

    context "adapter is sqlite3" do

      it "creates the sqlite3 database file" do
        SQLite3::Database.should_receive(:new).with( @config[:sqlite3][:database] )
        KitSupportDB::create @config[:sqlite3]
      end
    end
  end

  describe "destroy" do

    it "raises error if adapter not supported" do
      expect { KitSupportDB::destroy( :adapter => 'bad_adapter' ) }.should raise_error RuntimeError
    end

    context "adapter is sqlite3" do

      it "unlinks the sqlite3 databasefile " do
        File.should_receive(:unlink).with( @config[:sqlite3][:database] )
        KitSupportDB::destroy @config[:sqlite3]
      end
    end
  end

  describe "connect" do

    it "makes active record establish a connection" do
      ActiveRecord::Base.should_receive(:establish_connection).with( @config[:sqlite3] )
      KitSupportDB::create @config[:sqlite3]
      KitSupportDB::connect @config[:sqlite3], ActiveRecord::Base
    end
  end
end