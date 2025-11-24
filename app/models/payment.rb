class Payment < ApplicationRecord
  # Associations
  belongs_to :order

  # Validations (Feature 4.2.1)
  validates :amount, presence: true,
                     numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[pending completed failed refunded] }

  # Scopes
  scope :completed, -> { where(status: "completed") }
  scope :pending, -> { where(status: "pending") }
end
