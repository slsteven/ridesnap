# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  email                  :string(255)
#  phone                  :integer
#  password_digest        :string(255)
#  remember_token         :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  password_reset_token   :string(255)
#  password_reset_sent_at :datetime
#  zip_code               :string(255)
#  status                 :string(255)
#

require 'rails_helper'

RSpec.describe User, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
