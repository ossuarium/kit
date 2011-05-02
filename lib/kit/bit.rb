class Bit < Kit

	attr_reader :id

	# Loads all bit info from database, or attempts to add new bit to database
	# @param [Integer, Hash] info id of bit or info for new bit
	def initialize info

		@id = if info.is_a? Integer
						info
					else
						make_ivars info
						insert_new
					end

		load_info

	end

	# Sets instance variables for each key => value pair
	def make_ivars hash
		hash.each do |ivar, val|
			self.class.send :attr_accessor, ivar unless respond_to? ivar
			send "#{ivar}=", val
		end
	end

	# Add a task to the array of pending tasks in @tasks.
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

	# Runs all tasks in the list of pending tasks in @tasks and returns the status of each run task.
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

	class DuplicateElement < RuntimeError
	end

	class NoElement < RuntimeError
	end

end

