module Actions

	def clones options
		src = Bit.new options[:src]
		puts "cloning #{src.project_name}.#{src.name} to #{@project_name}.#{@name}"
	end

end