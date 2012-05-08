require 'kit'

describe Kit do

  before :all do
    @kit_path = File.expand_path '../../test_kit', __FILE__
    @config_file = File.expand_path '../../test_kit/config.yml', __FILE__
    @config = YAML.load( File.read "#{@kit_path}/config.yml" )
  end

  subject { Kit.new @config_file }

  describe ".path" do

    it "determines the correct path to the kit" do
      subject.path.should == @kit_path
    end
  end

  describe ".config" do

    it "loads the config file" do
      subject.config.should == @config
    end
  end

  describe ".open" do

    it "creates a new kit and opens a database connections" do
      Kit.any_instance.should_receive(:db_connect)
      Kit.open @config_file
    end
  end

  { create: nil, destroy: nil, connect: [Class.new] }.each do |action, args|

    describe ".db_#{action}" do

      it "calls KitDBSupport::#{action}" do
        if args.nil?
          KitDBSupport.should_receive(action).with( kind_of Hash )
          subject.send "db_#{action}", :kit
        else
          KitDBSupport.should_receive(action).with( kind_of(Hash), *( args.map { |x| kind_of(x.class) } ) )
          subject.send "db_#{action}", :kit, *args
        end
      end

      it "calls KitDBSupport::#{action} for all databases" do
        KitDBSupport.should_receive(action).exactly( subject.config[:db].length ).times
        subject.send "db_#{action}", :all, *args
      end
    end
  end
end