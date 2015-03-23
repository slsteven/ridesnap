# == Schema Information
#
# Table name: notifications
#
#  id         :integer          not null, primary key
#  vehicle_id :integer
#  type       :string
#  details    :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  ended_at   :datetime
#
# Indexes
#
#  index_notifications_on_ended_at    (ended_at)
#  index_notifications_on_type        (type)
#  index_notifications_on_vehicle_id  (vehicle_id)
#

class Location < Notification
  # CONTINUOUS
  # STATECHANGE
  # INITIAL
  # ONETIME
end
