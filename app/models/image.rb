# == Schema Information
#
# Table name: images
#
#  id         :integer          not null, primary key
#  vehicle_id :integer
#  url        :string(255)
#  default    :boolean
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_images_on_vehicle_id  (vehicle_id)
#

class Image < ActiveRecord::Base
end
