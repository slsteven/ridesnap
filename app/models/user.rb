# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  email           :string(255)
#  phone           :integer
#  password_digest :string(255)
#  remember_token  :string(255)
#  admin           :boolean          default(FALSE)
#  created_at      :datetime
#  updated_at      :datetime
#

class User < ActiveRecord::Base

  has_many :rides
  has_many :vehicles, through: :rides

  before_save { self.email = email.downcase.strip }
  before_create :create_remember_token

  validates :name, presence: true, length: { maximum: 50 }
  # validates :password, length: { minimum: 6 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true,
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password validations: false

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

  def self.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def self.generate_token
    SecureRandom.urlsafe_base64
  end

  def send_password_reset
    self.password_reset_token = User.generate_token
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end

  private

    def create_remember_token
      self.remember_token = User.digest(User.generate_token)
    end

end
