class Kit::Permission < ActiveRecord::Base

  belongs_to :user
  belongs_to :bit

end
