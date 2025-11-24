class ProductCategory < ApplicationRecord
  belongs_to :product
  belongs_to :category

  # Uniqueness verification -prevent duplicate associations
  validates :product_id, uniqueness: { scope: :category_id }
  def self.ransackable_attributes(auth_object = nil)
    [ "category_id", "created_at", "id", "product_id", "updated_at" ]
  end
end
