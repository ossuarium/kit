namespace 'mk' do

  task :migration, :name do |_, args|
    make_class_template "migrations/#{Time.now.utc.strftime('%Y%m%d%H%M%S')}_#{args[:name]}.rb", "class #{args[:name].camelize} < ActiveRecord::Migration"
  end

  task :model, :name do |_, args|
    make_class_template "models/#{args[:name]}.rb", "class Kit::#{args[:name].camelize} < ActiveRecord::Base"
  end
end
