# == Schema Information
#
# Table name: cities
#
#  id         :integer          not null, primary key
#  city       :string
#  state      :string
#  country    :string
#  requests   :integer          default("0")
#  available  :boolean          default("false")
#  created_at :datetime
#  updated_at :datetime
#

class City < ActiveRecord::Base
end
