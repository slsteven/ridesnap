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
  # hstore_accessor :options,
  #   colors: :hash,
  #   options: :hash,
  #   engines: :hash,
  #   transmissions: :hash

  has_many :rides
  has_many :users, through: :rides

  before_create :build_options

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
      transitions from: :listed, to: :pending
    end

    event :sell do |user|
      transitions to: :sold
    end
  end

  def color
    self.options[:colors][:exterior].select{ |h| h[:equipped] }[0] rescue nil
  end

  def engine
    self.options[:transmissions].select{ |h| h[:equipped] }[0] rescue nil
  end

  def transmission
    self.options[:engines].select{ |h| h[:equipped] }[0] rescue nil
  end

  def known_attr
    known = []
    known << "#{self.condition} condition" if self.condition
    known << "#{number_with_delimiter self.mileage} miles" if self.mileage
    known << self.color if self.color
    known << self.transmission if self.transmission
    known << self.engine if self.engine
    known
  end

  # def options
  #   if !read_attribute(:options).nil?
  #     OpenStruct.new read_attribute(:options)
  #   else
  #     nil
  #   end
  # end

  private

    def build_options
      return unless self.options.nil?
      tries = 0
      begin
        # 4 external calls to Edmunds API, hence the rescue block, just in case
        self.options = { colors: Edmunds.query_colors(self.style),
                         options: Edmunds.query_options(self.style),
                         engines: Edmunds.query_engines(self.style),
                         transmissions: Edmunds.query_transmissions(self.style) }
        tries += 1
      rescue
        retry if tries <= 3
        return nil
      end
    end

end
