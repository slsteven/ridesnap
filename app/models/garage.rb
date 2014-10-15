# == Schema Information
#
# Table name: garages
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  vehicle_id :integer
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_garages_on_user_id     (user_id)
#  index_garages_on_vehicle_id  (vehicle_id)
#

class Garage < ActiveRecord::Base
  belongs_to :user
  belongs_to :vehicle
end
