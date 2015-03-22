# == Schema Information
#
# Table name: vehicles
#
#  id                :integer          not null, primary key
#  make              :string
#  model             :string
#  year              :integer
#  style             :string
#  description       :text
#  mileage           :integer
#  condition         :integer
#  options           :hstore
#  preliminary_value :hstore
#  sold_price        :decimal(, )
#  status            :string
#  inspection        :boolean
#  zip_code          :string
#  created_at        :datetime
#  updated_at        :datetime
#  closest_color     :string
#  vin               :string
#  agreed_value      :decimal(, )
#  financed          :boolean
#  model_pretty      :string
#  external_ad       :string
#  report            :jsonb            default("{}")
#  option_list       :jsonb            default("{}")
#
# Indexes
#
#  index_vehicles_on_closest_color  (closest_color)
#  index_vehicles_on_condition      (condition)
#  index_vehicles_on_status         (status)
#  index_vehicles_on_zip_code       (zip_code)
#

class Vehicle < ActiveRecord::Base
  include LocationConcern
  include AASM
  include ActionView::Helpers::NumberHelper
  include Carvoyant

  extend FriendlyId
  friendly_id :vin

  enum condition: { Outstanding: 5, Clean: 4, Average: 3, Rough: 2, Damaged: 1 }

  hstore_accessor :preliminary_value,
    ride_snap: :integer,
    trade_in: :integer,
    snap_up: :integer

  alias_attribute :list_price, :agreed_value

  has_many :rides, dependent: :delete_all
  has_many :users, through: :rides

  has_many :images, dependent: :delete_all

  validates :make, presence: true
  validates :model, presence: true
  validates :year, presence: true

  before_create :build_options
  before_save do
    self.closest_color = base_color
    self.vin ||= Vehicle.generate_vin
    self.agreed_value ||= self.ride_snap
  end
  # before_update :update_s3_folder, if: :vin_changed?

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
      transitions to: :sold, after: :sold_to
    end
  end

  def sold_to(user)
    rides.create(user_id: user, relation: 'buyer')
  end

  # # # # #
  # /AASM
  # # # # #

  def info
    "#{year} #{make(pretty: true)} #{model(pretty: true)} - #{description}"
  end

  # getters for prettified text
  def make(pretty: false)
    mk = read_attribute(:make)
    pretty ? Settings.vehicle_makes[mk] : mk
  rescue
    read_attribute(:make)
  end
  def model(pretty: false)
    pretty ? read_attribute(:model_pretty) : read_attribute(:model)
  rescue
    read_attribute(:model)
  end

  def base_color
    unless self.color.present? && self.color.first[1][:primary]
      return %w(black white grey red yellow green cyan blue magenta).sample
    end
    color = Color::RGB.from_html(self.color.first[1][:primary]).to_hsl
    hue = color.hue
    sat = color.saturation
    lgt = color.luminosity

    case
    when lgt < 20  then 'black'
    when lgt > 80  then 'white'

    when sat < 25 then 'grey'

    when hue < 30   then 'red'
    when hue < 90   then 'yellow'
    when hue < 150  then 'green'
    when hue < 210  then 'cyan'
    when hue < 270  then 'blue'
    when hue < 330  then 'magenta'
    else 'red'
    end
  end

  def build_report
    self.report = {
      'fluid levels' => {
        "Engine Oil" => 'good',
        "Transmission Oil" => 'fair',
        "Brake Fluid" => 'fair',
        "Power Steering" => 'good',
        "Coolant" => 'good',
        "Engine Leaks" => 'good',
        "Transmission Leaks" => 'good',
        "Radiator Leaks" => 'good'
      }, 'engine' => {
        "Drive/timing belt" => 'good',
        "Electric Cooling Fan" => 'good',
        "ignition" => 'good',
        "battery" => 'fair',
        "corrosion" => 'good',
        "case leaking" => 'good',
        "load test" => 'good',
        "voltage" => 'fair'
      }, 'tires' => {
        "front left" => 'good',
        "front right" => 'good',
        "rear left" => 'good',
        "rear right" => 'good'
      }, 'brakes' => {
        "rotors" => 'good',
        "pads" => 'poor',
        "calipers" => 'good'
      }, 'suspension' => {
        "Alignment" => 'good',
        "weird noises" => 'fair',
        "Shocks/Struts" => 'good',
        "Movement" => 'good',
        "Tie-rod Ends" => 'good',
        "Ball Joints" => 'good',
        "Control Arms" => 'good'
      }, 'dash and electronics' => {
        "Check Engine Lights" => 'good',
        "Power Mirrors" => 'good',
        "Heat/AC" => 'good',
        "Alarm" => 'good',
        "Windows" => 'good'
      }, 'exterior' => {
        "Rust and Corrosion" => 'good',
        "dents" => 'good',
        'dings' => 'good',
        'scuffs' => 'fair'
      }, 'interior' => {
        "Carpets" => 'good',
        "Dash and Door Panels" => 'good',
        "Console" => 'good',
        "Seats and head rest" => 'fair'
      }, 'title' => {
        "paperwork" => 'good',
        "overall mechanic's report" => 'good',
        "Overall Exterior and Interior Report" => 'good'
      }, 'test drive summary' => {
        "Speedometer" => 'good',
        "How does the engine sound?" => 'good',
        "Does transmission shift gears smoothly?" => 'fair',
        "Alignment?" => 'good',
        "Does the car vibrate when the brakes are applied?" => 'good',
        "Suspension absorbs bumps normally?" => 'good'
      }
    }
  end
  def report(type=nil)
    rpt = if self.read_attribute(:report).blank?
      build_report
    else
      self.read_attribute(:report)
    end
    case type.to_s.downcase
    when 'mechanical' then rpt.slice('fluid levels','engine','tires','brakes','suspension','dash and electronics')
    when 'cosmetic' then rpt.slice('exterior', 'interior')
    when 'summary' then rpt.slice('title', 'test drive summary')
    else rpt
    end
  end

  def rvr
    vin.presence[-6..-1]
  rescue
    ''
  end

  # # # # #
  # this builds all of the getter and setter methods for the option_list attribute
  # # # # #
  %w(colors options transmissions engines).each do |opt|
    define_method("available_#{opt}") do
      option_list[opt].with_indifferent_access
    end

    define_method("available_#{opt}=") do |val|
      option_list[opt] = val
    end

    define_method(opt == 'options' ? opt : opt.singularize) do
      self.send("available_#{opt}#{['exterior'] if opt == 'color'}").select{ |k,v| v['equipped'] == true } rescue nil
    end
  end

  def color=(c={})
    return unless c.present?
    clr = available_colors.each{ |k,v| v.each{ |ke,va| va['equipped'] = nil } }
    c.each do |type,col| # hash
      clr[type][col]['equipped'] = true
    end
    self.available_colors = clr
  end
  def engine=(e=nil)
    return unless e.present?
    eng = available_engines.each{ |k,v| v['equipped'] = nil }
    eng[e]['equipped'] = true
    self.available_engines = eng
  end
  def transmission=(t=nil)
    return unless t.present?
    trn = available_transmissions.each{ |k,v| v['equipped'] = nil }
    trn[t]['equipped'] = true
    self.available_transmissions = trn
  end
  def options=(o=[])
    return unless o.present?
    opt = available_options.each{ |k,v| v.each{ |ke,va| va['equipped'] = nil } }
    o.each do |op| # array
      opt.deep_find(op)[:equipped] = true
    end
    self.available_options = opt
  end

  def self.generate_vin
    # 17 characters
    SecureRandom.urlsafe_base64[0..16]
  end

private

  def build_options
    return unless option_list.empty?
    tries = 0
    begin
      # 4 external calls to Edmunds API, hence the rescue block, just in case
      self.available_colors = Edmunds.query_colors(style)
      self.available_options = Edmunds.query_options(style)
      self.available_engines = Edmunds.query_engines(style)
      self.available_transmissions = Edmunds.query_transmissions(style)
      self.save
      tries += 1
    rescue
      sleep 1
      retry if tries <= 3
      return nil
    end
    true
  end

  def update_s3_folder
    creds = ::Aws::Credentials.new(Settings.aws.access_key_id, Settings.aws.secret_access_key)
    s3 = ::Aws::S3::Resource.new(region: 'us-west-1', credentials: creds)
    bucket = Settings.aws.bucket
    s3.copy_object(bucket: bucket, copy_source: self.vin_was, key: self.vin)
    s3.delete_object(bucket: bucket, key: self.vin_was)
  end

end
