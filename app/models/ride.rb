# == Schema Information
#
# Table name: rides
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  vehicle_id :integer
#  relation   :string(255)
#  owner      :boolean
#  created_at :datetime
#  updated_at :datetime
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

end
