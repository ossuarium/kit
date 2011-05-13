class Bit < Kit

	# Exceptions.

	# Raised when element exists but was not expected.
	class DuplicateElement < RuntimeError
	end

	# Raised when no element exists.
	class NoElement < RuntimeError
	end

	attr_reader :id

	# Loads all bit info from database, or attempts to add new bit to database.
	# @param [Integer, Hash] info id of bit or info for new bit
	def initialize info
		@id = \
			if info.is_a? Integer
				info
			elsif info.is_a? Hash
				info.each do |key, value|
					instance_variable_set "@#{key}", value
				end
				g = @group_name if @group_name
				g = @group_id if @group_id
				self.group = g, info
				insert_new
			else
				fail TypeError
			end
		load_info
	end

	private

	# Set group by name or id.
	# @param [Integer, String] group id or info for group
	def group= group
		@group_id = group if group.is_a? Integer
		@group_name = group if group.is_a? String

		if @group_id.nil?
			g = @@db.select_info_by_name :groups, [ :rowid ], @group_name
			@group_id = if g.nil? then insert_new_group else g[:rowid] end
		end
	end

	class ::Array
		def hash_ivars obj, exclude = []
			h = {}
			self.each do |x|
				h[x] = obj.instance_variable_get "@#{x}" unless exclude.include? x
			end
			return h
		end
	end

	def insert_new
		fail DuplicateElement if lookup_id @@unique[:bits].hash_ivars self

		data = @@info[:bits].hash_ivars self, [ :rowid ]
		@@db.insert_info :bits, data
	end

	def insert_new_group
		fail DuplicateElement if @@db.select_info_by_name :groups, @@unique[:groups], @group_name

		data = @@info[:groups].hash_ivars self, [ :rowid, :name ]
		data[:name] = @group_name

		@@db.insert_info :groups, data
	end

	def load_info

		info = @@db.select_info_by_id :bits, @@info[:bits], @id
		fail NoElement unless info

		group_info = @@db.select_info_by_id :groups, @@info[:groups], info[:group_id]
		info[:group_name] = group_info[:name]
		group_info.delete :rowid
		group_info.delete :name

		info.merge! group_info
		info.delete :rowid

		info.each do |key, value|
			instance_variable_set "@#{key}", value
			self.class.send :attr_reader, key
			self.class.send :public, key
		end
	end

	public
	# Add a task to the array of pending tasks.
	# @param [Hash] task info for task
	def queue_task task
		@tasks = [] unless @tasks
		@tasks << task
	end

	def clear_task task
# 		action = task[:action]
# 		id = task[:rowid]
#
# 		@@db.delete_action_by_id action, id
	end

	# Runs all tasks in the list of pending tasks and returns the status of each run task.
	# @return [Hash] key is task id
	def run_all
		tasks = @tasks
		status = {}

		tasks.each do |t|
			a = t[:action]
			begin
				self.send a, t
				status[a] = "complete"
			rescue
				status[a] = "failed"
			end
			status
		end
	end

	def lookup_id criteria
		@@db.select_info_by_criteria :bits, [:rowid], criteria
	end


end

