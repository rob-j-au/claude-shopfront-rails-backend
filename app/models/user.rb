class User
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  field :first_name, type: String
  field :last_name, type: String
  
  # Devise fields for Mongoid
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time
  field :remember_created_at,    type: Time
  
  # API Token fields
  field :api_token, type: String
  field :api_token_expires_at, type: Time

  has_many :orders, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
  
  def admin?
    false # Default implementation - can be extended later
  end
  
  # API Token methods
  def generate_api_token!
    self.api_token = SecureRandom.hex(32)
    self.api_token_expires_at = 30.days.from_now
    save!
    api_token
  end
  
  def api_token_valid?
    api_token.present? && api_token_expires_at.present? && api_token_expires_at > Time.current
  end
  
  def revoke_api_token!
    self.api_token = nil
    self.api_token_expires_at = nil
    save!
  end
  
  def self.find_by_api_token(token)
    return nil if token.blank?
    user = where(api_token: token).first
    return nil unless user&.api_token_valid?
    user
  end
end
