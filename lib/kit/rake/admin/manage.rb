namespace 'add' do

  desc 'Add a new group named "name" and create an action module actions/name.rb'
  task :group, :name do |_, args|
    kit = Kit.open 'config.yml'
    Kit::Group.create :name => args[:name].gsub('_', ' ')
    make_class_template "actions/#{args[:name]}.rb", "module KitActions#{args[:name].camelize}"
  end
end
