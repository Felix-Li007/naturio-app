class Page < ApplicationRecord
  # Validations (Feature 4.2.1)
  validates :title, presence: true, length: { maximum: 100 }
  validates :slug, presence: true,
                   uniqueness: true,
                   length: { maximum: 50 },
                   format: { with: /\A[a-z0-9-]+\z/,
                             message: "only lowercase letters, numbers, and hyphens" }
  validates :content, presence: true

  # Find by slug
  def self.find_by_slug(slug)
    find_by(slug: slug)
  end

   def self.ransackable_attributes(auth_object = nil)
    [ "content", "created_at", "id", "id_value", "slug", "title", "updated_at" ]
  end
end
