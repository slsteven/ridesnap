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

require 'rails_helper'

RSpec.describe Ride, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
