Gem::Specification.new do |spec|
	spec.name = 'kit'
	spec.version = '0.1.2'

	spec.author = 'Evan Boyd Sosenko'
	spec.summary = 'Extendable tool to manage site development and more.'

	spec.description = <<-EOF
		Kit is a framework for making simple management tools called kits.
	EOF

	spec.required_ruby_version = '>= 1.9.2'

	spec.add_dependency 'sqlite3', '>= 1.3.3'

	spec.requirements = 'SQLite3'

	require 'rake' # need this to use FileList
	spec.files = FileList[ 'lib/**/*.rb', '[A-Z]*' ].to_a

	spec.license = 'GPL-3'
end
