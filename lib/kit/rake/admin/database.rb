namespace 'db' do

  kit = Kit.new 'config.yml'

  task :create do
    kit.db_create
  end

  task :destroy do
    kit.db_destroy
  end

  task :reset => [:destroy, :create, :migrate] do
  end

  task :environment do
    kit.db_connect
  end

  task :migrate, [:direction, :steps]  => [:create, :environment] do |_, args|
    args.with_defaults(direction: nil, steps: 1)
    if args[:direction].nil?
      kit.db_migrate
    else
      kit.db_migrate args[:direction], args[:steps]
    end
  end
end