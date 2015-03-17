# == Schema Information
#
# Table name: codes
#
#  id          :integer          not null, primary key
#  code        :string
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_codes_on_code  (code)
#

class Code < ActiveRecord::Base
  # Diagnostic Trouble Codes
end
