# == Schema Information
#
# Table name: vehicles
#
#  id                :integer          not null, primary key
#  make              :string(255)
#  model             :string(255)
#  year              :integer
#  style             :string(255)
#  description       :text
#  mileage           :integer
#  condition         :string(255)
#  options           :hstore
#  preliminary_value :hstore
#  agreed_value      :hstore
#  sold_price        :decimal(, )
#  status            :string(255)
#  inspection        :boolean
#  zip_code          :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

class Vehicle < ActiveRecord::Base
  include AASM
  include ActionView::Helpers::NumberHelper

  hstore_accessor :preliminary_value,
    private_party: :integer,
    trade_in: :integer
  hstore_accessor :agreed_value,
    private_party: :integer,
    buy_it_now: :integer
  # hstore_accessor :options

  has_many :rides
  has_many :users, through: :rides

  # these states give us helper methods as follows
  # Vehicle.listed === Vehicle.where(status: 'listed')
  # Vehicle#listed? === Vehicle.first.status == 'listed'
  aasm column: 'status' do
    state :preliminary, initial: true
    state :listed
    state :pending
    state :sold

    event :list do
      transitions from: :preliminary, to: :listed
    end

    event :sell? do
      puts 'pending sale'
      transitions from: :listed, to: :pending
    end

    event :sell do |user|
      puts "sold to #{user.name}!!"
      transitions to: :sold
    end
  end

  def options
    OpenStruct.new read_attribute(:options)
  end

  def known_attr
    known = []
    known << "#{self.condition} condition" if self.condition
    known << "#{number_with_delimiter self.mileage} miles" if self.mileage
    known << self.options.color if self.options.color
    known << self.options.transmission if self.options.transmission
    known << self.options.engine if self.options.engine
    known
  end

end
