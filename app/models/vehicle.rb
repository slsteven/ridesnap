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
#  condition         :integer
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
# Indexes
#
#  index_vehicles_on_condition  (condition)
#  index_vehicles_on_status     (status)
#  index_vehicles_on_zip_code   (zip_code)
#

class Vehicle < ActiveRecord::Base
  include AASM
  include ActionView::Helpers::NumberHelper
  enum condition: { outstanding: 5, clean: 4, avg: 3, rough: 2, damaged: 1 }

  hstore_accessor :preliminary_value,
    private_party: :integer,
    trade_in: :integer
  hstore_accessor :agreed_value,
    private_party: :integer,
    buy_it_now: :integer

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
      transitions from: [:preliminary, :pending], to: :listed
    end

    event :sell? do
      transitions from: :listed, to: :pending
    end

    event :sell do
      transitions to: :sold, on_transition: :sold_to
    end
  end

  def sold_to(user)
    rides.create(user_id: user, relation: 'buyer')
  end

  # # # # #
  # /AASM
  # # # # #

  def options
    return nil if read_attribute(:options).nil?
    eval(read_attribute(:options)['options'])
  end

  def options=(e: nil, t: nil, o: [], c: {})
    engine = engines.each{|k,v| v[:equipped] = nil}
    engine[e][:equipped] = true

    transmission = transmissions.each{|k,v| v[:equipped] = nil}
    transmission[t][:equipped] = true

    option = options.each{|k,v| v.each{|ke,va| va[:equipped] = nil}}
    o.each do |opt| # array
      option.deep_find(opt)[:equipped] = true
    end

    color = colors.each{|k,v| v.each{|ke,va| va[:equipped] = nil}}
    c.each do |type,col| # hash
      color[type][col][:equipped] = true
    end

    write_attribute :options, { colors: color,
                                options: option,
                                engines: engine,
                                transmissions: transmission }
  end

  def color
    self.colors['exterior'].select{ |k,v| v[:equipped] == true } rescue nil
  end

  def base_color
    return '' unless self.color.presence && self.color.first[1][:primary]
    hue = Color.new(self.color.first[1][:primary]).hue
    sat = Color.new(self.color.first[1][:primary]).saturation
    lgt = Color.new(self.color.first[1][:primary]).luminosity

    case
    when lgt < 0.2  then 'black'
    when lgt > 0.8  then 'white'

    when sat < 0.25 then 'grey'

    when hue < 30   then 'red'
    when hue < 90   then 'yellow'
    when hue < 150  then 'green'
    when hue < 210  then 'cyan'
    when hue < 270  then 'blue'
    when hue < 330  then 'magenta'
    else 'red'
    end
  end

  def colors
    return nil if read_attribute(:options).nil?
    eval(read_attribute(:options)['colors'])
  end

  def engine
    self.engines.select{ |k,v| v[:equipped] == true } rescue nil
  end

  def engines
    return nil if read_attribute(:options).nil?
    eval(read_attribute(:options)['engines'])
  end

  def transmission
    self.transmissions.select{ |k,v| v[:equipped] == true } rescue nil
  end

  def transmissions
    return nil if read_attribute(:options).nil?
    eval(read_attribute(:options)['transmissions'])
  end

  def known_attr
    known = []
    known << "#{self.condition} condition" if self.condition
    known << "#{number_with_delimiter self.mileage} miles" if self.mileage
    known << self.color.first[1][:name] if self.color.any?
    known << self.engine.first[1][:name] if self.engine
    known << self.transmission.first[1][:description] if self.transmission
    known
  end

private

  def build_options
    return unless read_attribute(:options).nil?
    tries = 0
    begin
      # 4 external calls to Edmunds API, hence the rescue block, just in case
      write_attribute :options, { colors: Edmunds.query_colors(self.style),
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
