class Kit::User < ActiveRecord::Base

  has_many :permissions
  has_many :bits, :through => :permissions

end