class Address < ApplicationRecord
  belongs_to :customer
  belongs_to :province
  has_many :orders, dependent: :restrict_with_error

  # Validations (Feature 4.2.1)
  validates :street_address, presence: true, length: { maximum: 255 }
  validates :city, presence: true, length: { maximum: 100 }
  validates :postal_code, presence: true,
                          format: { with: /\A[A-Za-z]\d[A-Za-z][ -]?\d[A-Za-z]\d\z/,
                                    message: "must be valid Canadian postal code" }
  validates :address_type, inclusion: { in: %w[shipping billing] }

  # Methods
  def full_address
    "#{street_address}, #{city}, #{province.code} #{postal_code}"
  end
end
