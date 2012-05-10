class Kit::Bit < ActiveRecord::Base

  belongs_to :group
  has_many :permissions
  has_many :users, :through => :permissions

  after_initialize do
    self.extend Kernel.const_get("KitActions#{self.group.name.gsub(' ', '_').camelize}")
  end
end