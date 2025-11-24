class OrderItem < ApplicationRecord
  # Associations
  belongs_to :order
  belongs_to :product

  # Validations (Feature 4.2.1)
  validates :quantity, presence: true,
                       numericality: { greater_than: 0, only_integer: true }
  validates :purchase_price, presence: true,
                             numericality: { greater_than: 0 }
  validates :subtotal, presence: true,
                       numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_validation :set_purchase_price, on: :create
  before_save :calculate_subtotal

  private

  def set_purchase_price
    self.purchase_price ||= product&.price
  end

  def calculate_subtotal
    self.subtotal = quantity * purchase_price
  end
end
