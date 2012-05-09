class Kit::Bit < ActiveRecord::Base

  belongs_to :group
  has_many :permissions
  has_many :users, :through => :permissions

end