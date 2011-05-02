require 'yaml'

class Kit
	# Loads the settings for the kit.
	# @param [String, Hash] config path to kit config file or hash of kit settings
	def initialize config

		config = load_config_file config if File.exists? config

		fail "No path to kit set" unless config[:kits_path]

		@@kit_path = config[:kits_path]

		defaults = YAML.load File.read @@kit_path + "/config.yml"
		config = defaults.merge config

		load 'kit/db_sqlite3.rb' if config[:db_backend] == :sqlite3

		load @@kit_path + "/bit.rb"

		@@db = Backend.new config[:db_config]
		@@info = config[:info]
		@@actions = config[:actions]
	end

	def action_types
		@@actions.keys
	end

	# Converts a kit config file into a hash of kit settings.
	# @param [String] file path to a kit config file in yaml format
	# @return [Hash] kit settings
	def load_config_file file

		config = YAML.load File.read file
		@@config_path = File.absolute_path File.dirname file

		dir = config[:kits_path]
		dir = if config[:kits_path].nil?
						@@config_path
					else
						File.absolute_path @@config_path + config[:kits_path] unless [ "/", "~" ].include? config[:kits_path][0]
					end

		config[:kits_path] = dir
		return config
	end

	# Deletes the kit's databases
	def delete_dbs
		@@db.db_paths.each do |key, f|
			File.delete f
		end
	end

	# Creates bit object if it is unique enough.
	# @param [Hash] info requested initial properties of the bit
	# @return [Bit, nil] the new bit or nil if too similar to a bit that already exists
	def add_bit info
		begin
			Bit.new info
		rescue Bit::DuplicateElement
			nil
		end
	end

	def get_bit info
		begin
			if info.is_a? Integer
				Bit.new info
			elsif info_is_a? Hash
				Bit.new Bit::lookup_id info
			end
		rescue NoElement
			nil
		end
	end

	# Adds a new task to the corresponding action table.
	# @param [Symbol] action name of the action type
	# @param [Hash] options options for the corresponding action type
	def add_task action, options
		fail NoAction unless @@actions.include? action
		@@db.insert_action action, options
	end

	# Runs all pending tasks.
	def run_tasks
		collect_tasks_by_bit.each do |bit, tasks|
			b = Bit.new bit

			actions = tasks.group_by { |t| t[:action] } . keys

			actions.each do |a|
				load @@kit_path + "/#{a}/#{b.project_name}.rb"
				b.extend Actions
			end

			tasks.each do |t|
				b.queue_task t
			end

			b.run_all
			# TODO try and use yields here to set status to running and then complete / failed as each task runs and finishes
		end
	end

	def get_tasks_by_status action, status
		@@db.select_all_actions_by_status action, @@actions[action], status
	end

	private
	# Gets all tasks and groups them by bit.
	# @return [Hash{Integer => Hash}] tasks grouped by bit id
	def collect_tasks_by_bit

		tasks = []
		@@actions.each_key do |action|
			tasks.push get_tasks_by_status action, :pending
		end
		tasks.flatten!

		tasks.group_by { |t| t[:bit] }
	end

	class NoAction < StandardError
	end

end

require 'kit/bit'
