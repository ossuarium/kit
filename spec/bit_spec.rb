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

  describe Kit::Bit::Job do

    subject { Kit::Bit::Job.new @config_file, 1, :the_action, :arg_1, :arg_2 }

    describe ".perform" do

      before :each do
        @bit = mock('Kit::Bit', :id => 1, :the_action => nil)
        Kit::Bit.stub(:find).and_return(@bit)
      end

      it "opens the kit" do
        Kit.should_receive(:open).with(@config_file)
        subject.perform
      end

      it "looks for the bit" do
        Kit::Bit.should_receive(:find).with(1)
        subject.perform
      end

      it "runs the action on the bit" do
        @bit.should_receive(:the_action).with(:arg_1, :arg_2)
        subject.perform
      end
    end
  end
end