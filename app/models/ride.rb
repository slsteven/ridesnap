# == Schema Information
#
# Table name: rides
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  vehicle_id :integer
#  datetime   :datetime
#  relation   :string(255)
#  owner      :boolean
#  address    :string(255)
#  zip_code   :string(255)
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
