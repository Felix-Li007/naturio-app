class Province < ApplicationRecord
  # Associations
  has_many :addresses, dependent: :restrict_with_error

  # Validations (Feature 4.2.1)
  validates :name, presence: true,
                   uniqueness: true,
                   length: { maximum: 50 }
  validates :code, presence: true,
                   uniqueness: true,
                   length: { is: 2 }
  validates :gst_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :pst_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :hst_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  # Methods
  def total_tax_rate
    gst_rate + pst_rate + hst_rate
  end

  def display_name
    "#{name} (#{code})"
  end

   def self.ransackable_attributes(auth_object = nil)
    [ "code", "created_at", "gst_rate", "hst_rate", "id", "id_value", "name", "pst_rate", "updated_at" ]
  end
end
