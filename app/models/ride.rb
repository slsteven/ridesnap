# == Schema Information
#
# Table name: rides
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  vehicle_id   :integer
#  scheduled_at :datetime
#  relation     :integer
#  address      :string(255)
#  zip_code     :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  cancel       :boolean          default(FALSE)
#
# Indexes
#
#  index_rides_on_relation    (relation)
#  index_rides_on_user_id     (user_id)
#  index_rides_on_vehicle_id  (vehicle_id)
#

class Ride < ActiveRecord::Base
  include LocationConcern

  enum relation: { inspector: 1, seller: 2, tester: 3, buyer: 4 }

  belongs_to :user
  belongs_to :vehicle

  default_scope { where.not(scheduled_at: nil).order(created_at: :asc) }

  def confirm_ride
    RideMailer.confirm_with_user(self.id).deliver
    RideMailer.confirm_with_agent(self.id).deliver
  end

  def with?(user)
    user_id == user.try(:id)
  end

end
