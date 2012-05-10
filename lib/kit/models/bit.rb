class Kit::Bit < ActiveRecord::Base

  belongs_to :group
  has_many :permissions
  has_many :users, :through => :permissions

  after_initialize do
    unless self.group.nil?
      mod = "KitActions#{self.group.name.gsub(' ', '_').camelize}"
      self.extend Kernel.const_get(mod) if Kernel.const_defined? mod
    end
  end

  class Job

    def initialize config_file, bit_id, action, *args
      @config_file = config_file
      @bit_id = bit_id
      @action = action
      @args = *args
    end

    def perform
      Kit.open @config_file
      Kit::Bit.find(@bit_id).send(@action, *@args)
    end
  end
end