namespace 'db' do

  kit = Kit.new 'config.yml'

  desc %q{Create the kit's database}
  task :create do
    kit.db_create
  end

  desc %q{Destroy the kit's database}
  task :destroy do
    kit.db_destroy
  end

  desc %q{Reset the kit's database to an empty state and run all migrations}
  task :reset => [:destroy, :create, :migrate] do
  end

  task :environment do
    kit.db_connect
  end

  desc %q{Fully migrate the kit's database: optionally specify the direction and how many steps (1 by default)}
  task :migrate, [:direction, :steps]  => [:create, :environment] do |_, args|
    args.with_defaults(direction: nil, steps: 1)
    if args[:direction].nil?
      kit.db_migrate
    else
      kit.db_migrate args[:direction], args[:steps]
    end
  end
end
