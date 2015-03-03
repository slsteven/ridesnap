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

require 'rails_helper'

RSpec.describe City, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
