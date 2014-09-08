# == Schema Information
#
# Table name: cities
#
#  id         :integer          not null, primary key
#  city       :string(255)
#  state      :string(255)
#  country    :string(255)
#  requests   :integer          default(0)
#  available  :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

class City < ActiveRecord::Base
end
