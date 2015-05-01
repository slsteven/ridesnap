# == Schema Information
#
# Table name: authentications
#
#  id         :integer          not null, primary key
#  type       :string
#  grant      :string
#  token      :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_authentications_on_type  (type)
#

class Authentication < ActiveRecord::Base
  default_scope { order(created_at: :desc) }
end
