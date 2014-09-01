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

  # validates :name, length: { maximum: 50 }
  # validates :password, length: { minimum: 6 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true,
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password validations: false

  def self.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def self.new_remember_token
    SecureRandom.urlsafe_base64
  end

  private

    def create_remember_token
      self.remember_token = User.digest(User.new_remember_token)
    end

end
