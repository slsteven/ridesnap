# == Schema Information
#
# Table name: authentications
#
#  id         :integer          not null, primary key
#  vehicle_id :integer
#  type       :string
#  grant      :string
#  token      :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_authentications_on_type        (type)
#  index_authentications_on_vehicle_id  (vehicle_id)
#

class Authentication < ActiveRecord::Base
  default_scope { order(created_at: :desc) }
end
