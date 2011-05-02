require 'kit'

describe Kit do

	MY_KIT_CONFIG = "spec/my_kit/my_kit.yml"

	before :all do
		@kit = Kit.new MY_KIT_CONFIG
	end

	it "adds a new bit to new project" do
		new_bit = { :name => "live", :project_name => "my_project", :root => "./my_kit_spec/my_project", :git => "git path" }
		b = @kit.add_bit new_bit

		b.class.should == Bit

		new_bit.each do |key, value|
			( b.send key ).should == value
		end
	end

	it "doen not add a existing bit to project" do
		new_bit = { :name => "live", :project_name => "my_project", :root => "./my_kit_spec/my_project/live" }
		b = @kit.add_bit new_bit

		b.should == nil

	end

	it "adds a new task of each type" do

# 		old_bit = { :name => "live", :project_name => "my_project" }
# 		puts Kit::Bit.lookup_id old_bit

		new_bit_2 = { :name => "beta", :project_name => "my_project", :root => "./my_kit_spec/my_project/beta" }
		b = @kit.add_bit new_bit_2

		actions = {
			:clones => { :bit => 1, :src => 2 },
			:upgrades => { :bit => 1, :component => "my_component", :file => "my_file" },
			:commits => { :bit => 1, :commit => "3456ABF" }
		}

		tasks = {}
		actions.each do |key, value|
			tasks[key] = @kit.add_task key, value
		end

		@kit.action_types.each do |t|
			a = @kit.get_tasks_by_status t, :pending
			actions[t].merge! ( { :rowid => tasks[t], :action => t, :status => "pending" } )
			a.first.should == actions[t]
		end

	end

	it "runs added tasks" do
		@kit.run_tasks
	end


	after :all do
		@kit.delete_dbs
	end

end