class HomeController < ApplicationController
  def index
    # Featured products for homepage (Feature 2.1)
    @featured_products = Product.includes(:categories).with_attached_image.on_sale.limit(4)

    @new_products = Product.includes(:categories).with_attached_image.new_products.limit(4)

    @categories = Category.includes(:products).alphabetical
  end
end
