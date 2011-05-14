require 'yaml'

# Primary class for Kit.
class Kit

	require 'kit/bit'

	# Exceptions.

	# Raised when an action is specified that is not in the defined actions for the kit.
	class NoAction < RuntimeError
	end

	# Loads the settings for the kit.
	# @param [String, Hash] config path to kit config file or hash of kit settings
	def initialize config
		# Load the config and merge with the default config.
		config = load_config_file config if File.exists? config

		fail "No path to kit set" unless config[:kits_path]

		@@kit_path = config[:kits_path]
		defaults = YAML.load File.read @@kit_path + "/config.yml"
		config = defaults.merge config

		# Load backend for selected database type.
		load 'kit/db_sqlite3.rb' if config[:db_backend] == :sqlite3

		# Load class files for the kit
		begin
			load @@kit_path + "/bit.rb"
			load @@kit_path + "/kit.rb"
		rescue LoadError
		end

		# Set the class variables.
		@@info = config[:info]
		@@unique = config[:unique]
		@@actions = config[:actions]
		@@status_types = [ :pending, :completed, :queued ]
		@@db = Backend.new config[:db_config]

		# Run initialization specific to the kit.
		begin
			self.kit_initialize
		rescue NoMethodError
		end
	end

	# Kit related methods.

	# @return [Hash] names of actions defined for this kit
	def action_types
		@@actions.keys
	end

	# @return [Array] names of task status types defined for this kit
	def status_types
		@@status_types
	end

	# Deletes the kit's databases.
	def delete_dbs
		@@db.delete
	end

	# Bit related methods.

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

	# Gets a bit that matches id or info.
	# @param [Integer, Hash] bit id or hash of info unique enough to identify a bit
	# @return [Bit, nil] the Bit or nil if no unique bit could be found
	def get_bit info
		begin
			if info.is_a? Integer
				Bit.new info
			elsif info.is_a? Hash
				Bit.new Bit::lookup_id info
			end
		rescue Bit::NoElement
			nil
		end
	end

	# Task related methods.

	# Gets all tasks with requested status for one action type.
	# @param [Symbol] name of action type to get tasks for
	# @param [Symbol] task status
	# @return [Array] tasks for given action type with requested status
	def get_tasks_by_status action, status
		@@db.select_all_actions_by_status action, @@actions[action], status
	end

	# Adds a new task to the corresponding action table.
	# @param [Symbol] action name of the action type
	# @param [Hash] options options for the corresponding action type
	def add_task action, options
		begin
			fail NoAction, "#{action}" unless @@actions.include? action
			@@db.insert_action action, options
		rescue NoAction => ex
			puts "Could not add task: no such action: '#{ex.message}'."
		end
	end

	# Runs all pending tasks.
	def run_tasks
		collect_tasks_by_bit.each do |bit, tasks|
			b = get_bit bit
			next if b.nil?

			actions = tasks.group_by { |t| t[:action] } . keys
			actions.each do |a|
				load @@kit_path + "/actions/#{b.group_name}/#{a}.rb"
				b.extend Actions
			end

			tasks.each do |t|
				b.queue_task t
			end

			b.run_all
			# TODO try and use blocks here to set status to running and then complete / failed as each task runs and finishes
		end
	end

	private
	# Gets all pending tasks with requested status and groups them by bit.
	# @return [Hash{Integer => Hash}] tasks grouped by bit id
	def collect_tasks_by_bit
		tasks = []
		@@actions.each_key do |action|
			tasks.push get_tasks_by_status action, :pending
		end
		tasks.flatten!
		tasks.group_by { |t| t[:bit] }
	end

	# Converts a kit config file into a hash of kit settings.
	# @param [String] file path to a kit config file in YAML format
	# @return [Hash] kit settings
	def load_config_file file

		# Load the file using YAML.
		config = YAML.load File.read file
		@@config_path = File.absolute_path File.dirname file

		# Determine the path to the kit.
		config[:kits_path] = \
			if config[:kits_path].nil?
				@@config_path
			elsif ! [ "/", "~" ].include? config[:kits_path][0]
				File.absolute_path @@config_path + config[:kits_path]
			else
				config[:kits_path]
			end

		return config
	end

end