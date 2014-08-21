class Vehicle < ActiveRecord::Base
  include AASM

  aasm column: 'status' do

  end
end