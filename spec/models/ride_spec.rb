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

require 'rails_helper'

RSpec.describe Ride, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
