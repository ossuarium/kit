class Bit

	def lookup_id uniq
		@@db.select_info_by_criteria :bits, [:rowid], uniq
	end

	def insert_new

		if @project_id.nil?

			p = @@db.select_info_by_name :projects, [ :rowid ], @project_name

			@project_id = if p.nil? then insert_new_project else p[:rowid] end

		end

		uniq = { :name => @name, :project => @project_id }
		data = { :root => @root, :commit => nil, :commit_time => nil }

		fail DuplicateElement if lookup_id uniq

		data.merge! uniq

		@@db.insert_info :bits, data
	end

	def insert_new_project

		fail DuplicateElement if @@db.select_info_by_name :projects, [ :name ], @project_name

		data = { :name => @project_name, :git => @git }
		@@db.insert_info :projects, data
	end

	def load_info

		info = @@db.select_info_by_id :bits, @@info[:bits], @id

		fail NoElement unless info

		@name = info[:name]
		@project_id = info[:project]

		project_info = @@db.select_info_by_id :projects, @@info[:projects], @project_id
		info.merge! project_info

		@project_name = info[:name]
		@root = info[:root]
		@git = info[:git]
		@commit = { :name => info[:commit], :time => info[:commit_time] }

	end

end
