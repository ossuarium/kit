namespace 'mk' do

  def make_class_template file_name, class_line
    unless File.exists? file_name
      f = File.new file_name, 'w+'
      f << class_line
      f << "\nend"
      f.close
    end
  end

  task :migration, :name do |_, args|
    make_class_template "migrations/#{Time.now.to_i}_#{args[:name]}.rb", "class #{args[:name].camelize} < ActiveRecord::Migration"
  end

  task :model, :name do |_, args|
    make_class_template "models/#{args[:name]}.rb", "class Kit::#{args[:name].camelize} < ActiveRecord::Base"
  end
end