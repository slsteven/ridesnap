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
# Indexes
#
#  index_users_on_email   (email)
#  index_users_on_status  (status)
#

class User < ActiveRecord::Base
  include LocationConcern
  include AASM

  has_many :rides
  has_many :vehicles, -> { where(rides: {relation: %w(2 4)}) }, through: :rides
  has_many :favorites, through: :garage

  before_save do
    self.email = email.downcase.strip
    self.phone = phone.to_s.delete('^0-9').strip
  end
  before_create :create_remember_token

  # validates :name, presence: true, length: { maximum: 50 }
  # validates :password, length: { minimum: 6 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true,
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password validations: false

  # these states give us helper methods as follows
  # User.standard === User.where(status: 'standard')
  # User#standard? === User.first.status == 'standard'
  aasm column: 'status', whiny_transitions: false do
    state :standard, initial: true
    state :applicant
    state :agent
    state :admin

    event :apply_for_agent do
      transitions from: :standard, to: :applicant
    end

    event :promote_to_agent do
      transitions from: :applicant, to: :agent
    end
  end

  # # # # #
  # /AASM
  # # # # #

  def self.build(params={})
    u = User.find_by(email: params[:email])
    if u
      # user exists, and has already signed up
      if u.password_digest.present?
        u.update_attributes name: params[:name]
        return {object: u, status:'current user'}
      # user's email exists, but hasn't actually signed up
      else
        u.name = params[:name]
        u.password = params[:password]
        u.save # no name or password validations, so this should always succeed
        return {object: u, status:'returning user'}
      end
    # user doesn't exist, completely new record
    else
      u = User.new params.permit(:email, :name, :password)
      if u.save
        return {object: u, status:'fresh user'}
      else
        return {object: u}
      end
    end
  end

  def self.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def self.generate_token
    SecureRandom.urlsafe_base64
  end

  def first_name
    if %w[mr mr. dr dr. ms ms. mrs mrs.].include? self.name.split(' ').first.downcase
      self.name.split(' ')[1]
    else
      self.name.split(' ').first
    end
  end

  def last_name
    if %w[jr jr. sr sr. ii iii iv v].include? self.name.split(' ').last.downcase
      self.name.split(' ')[-2]
    else
      self.name.split(' ').last
    end
  end

  def owner?(vehicle)
    self.vehicles.include?(vehicle)
  end

  def send_password_reset
    self.password_reset_token = User.generate_token
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self.id).deliver
  end

private

  def create_remember_token
    self.remember_token = User.digest(User.generate_token)
  end

end
