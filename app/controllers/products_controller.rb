class ProductsController < ApplicationController
  before_action :set_product, only: [ :show ]
  before_action :set_categories, only: [ :index ]

  # GET /products (Feature 2.1, 2.2, 2.3， 2.4, 2.5，2.6)
  def index
    @products = Product.includes(:categories).with_attached_image

    # Filter by category (Feature 2.2)
    if params[:category].present?
      @current_category = Category.find_by(id: params[:category])
      @products = @products.joins(:product_categories).where(product_categories: { category_id: params[:category] })
    end

    # Filter by type (Feature 2.4)
    case params[:filter]
    when "on_sale"
      @products = @products.on_sale
      @filter_title = "On Sale"
    when "new"
      @products = @products.new_products

      @filter_title = "New Arrivals"
    when "recent"
      @products = @products.recently_updated
      @filter_title = "Recently Updated"
    end

    # Feature 2.6 ✯
    if params[:search].present?
      @search_term = params[:search].strip
      @products = @products.search_by_keyword(@search_term)
      @browsing_mode = :search

      if params[:search_category].present?
        @search_category = Category.find_by(id: params[:search_category])
        @products = @products.joins(:product_categories)
                             .where(product_categories: { category_id: params[:search_category] })
      end
    end

    # Sorting
    case params[:sort]
    when "price_asc"
      @products = @products.by_price_asc
    when "price_desc"
      @products = @products.by_price_desc
    when "name"
      @products = @products.alphabetical
    when "newest"
      @products = @products.order(created_at: :desc)
    else
      @products = @products.order(created_at: :desc)
    end

    # Pagination (Feature 2.5)
    @products = @products.page(params[:page]).per(12)
  end

  # GET /products/:id (Feature 2.3)
  def show
    @related_products = Product.includes(:categories).with_attached_image.joins(:product_categories).where(product_categories: {
                                 category_id: @product.category_ids
                               }).where.not(id: @product.id).distinct.limit(4)
  end

  private

  def set_product
    @product = Product.includes(:categories).find(params[:id])
  end

  def set_categories
    @categories = Category.alphabetical
  end
end
