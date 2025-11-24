class Customer < ApplicationRecord
  # Devise modules (Feature 3.1.4)
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :addresses, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error

  # Validations (Feature 4.2.1)
  validates :username, presence: true,
                       uniqueness: true,
                       length: { minimum: 3, maximum: 50 }
  validates :email, presence: true,
                    uniqueness: true,
                    length: { maximum: 50 }

  # Methods
  def primary_address
    addresses.find_by(address_type: "shipping") || addresses.first
  end

  def full_name
    username
  end

  # Explicitly specify which fields are searchable
  def self.ransackable_attributes(auth_object = nil)
    # List only the fields you want searchable in ActiveAdmin/Ransack
    [ "id", "email", "username", "created_at", "updated_at" ]
  end
end
