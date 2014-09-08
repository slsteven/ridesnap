# == Schema Information
#
# Table name: rides
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  vehicle_id   :integer
#  scheduled_at :datetime
#  relation     :string(255)
#  owner        :boolean
#  address      :string(255)
#  zip_code     :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Ride < ActiveRecord::Base
  include AASM

  belongs_to :user
  belongs_to :vehicle

  aasm column: 'relation' do
    state :seller
    state :buyer
    state :tester
  end

  def confirm_ride
    RideMailer.confirm_with_user(self.id).deliver
    RideMailer.confirm_with_agent(self.id).deliver
  end

end
