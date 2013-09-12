require 'kit'

describe Kit do

  before :all do
    @kit_path = File.expand_path '../../test-kit', __FILE__
    @config_file = File.expand_path '../../test-kit/config.yml', __FILE__
    @config = YAML.load File.read("#{@kit_path}/config.yml")
  end

  subject { Kit.new @config_file }

  describe "#path" do

    it "determines the correct path to the kit" do
      subject.path.should == @kit_path
    end
  end

  describe "#config" do

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

  db_actions              = {}
  db_actions[:destroy]    = [Hash.new]
  db_actions[:create]     = [Hash.new]
  db_actions[:migrate]    = [String.new, Hash.new, 0]
  db_actions[:migrate_to] = [String.new, 0]

  db_actions.each do |action, args|

    describe "#db_#{action}" do

      it "calls KitDBSupport::#{action}" do
        KitDBSupport.should_receive(action).with( *( args.map { |x| kind_of(x.class) } ) )
        subject.send "db_#{action}", *args[1..-1]
      end

      it "returns the instance of Kit" do
        KitDBSupport.stub action
        subject.send("db_#{action}", *args[1..-1]).should equal subject
      end
    end
  end
end
