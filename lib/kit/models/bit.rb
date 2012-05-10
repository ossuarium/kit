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
end