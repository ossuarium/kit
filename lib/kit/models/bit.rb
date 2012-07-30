class Kit::Bit < ActiveRecord::Base

  belongs_to :group
  has_many :permissions
  has_many :users, :through => :permissions

  after_initialize do
    self.extend KitActionsDefault
    unless self.group.nil?
      mod = "KitActions#{self.group.name.gsub(' ', '_').camelize}"
      self.extend Kernel.const_get(mod) if Kernel.const_defined? mod
    end
  end

  class Job

    def initialize *args
      if args[0].is_a? Hash
        hash = args[0]
        args = [ hash[:config_file], hash[:bit_id], hash[:action], *hash[:args] ]
      end
      @config_file = args[0]
      @bit_id      = args[1]
      @action      = args[2]
      @args        = *args[3..-1]
    end

    def perform
      Kit.open @config_file
      Kit::Bit.find(@bit_id).send(@action, *@args)
    end
  end
end