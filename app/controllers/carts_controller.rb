# Feature 3.1.1 ✯ （Session)
# Feature 3.1.2

class CartsController < ApplicationController
  before_action :initialize_cart
  before_action :set_product, only: [ :add, :update, :remove ]

  def show
    @cart_items = load_cart_items
    @cart_total = calculate_cart_total
  end

  # Feature 3.1.1 ✯
  def add
    quantity = (params[:quantity] || 1).to_i
    quantity = 1 if quantity < 1
    product_id = @product.id.to_s
    if session[:cart][product_id]
      session[:cart][product_id] += quantity
    else
      session[:cart][product_id] = quantity
    end
    # Check stock limits
    if session[:cart][product_id] > @product.stock_quantity
      session[:cart][product_id] = @product.stock_quantity
      flash[:warning] = "Quantity adjusted to available stock (#{@product.stock_quantity})."
    else
      flash[:notice] = "#{@product.name} added to cart."
    end

    redirect_back(fallback_location: cart_path)
  end

  # Feature 3.1.2
  def update
    quantity = params[:quantity].to_i
    product_id = @product.id.to_s

    if quantity <= 0
      # When the quantity is 0 or negative, it will not be automatically deleted and the user will be prompted to use the delete button.
      flash[:alert] = "Quantity must be at least 1. Use remove button to delete item."
      redirect_to cart_path and return
    end

    if quantity > @product.stock_quantity
      quantity = @product.stock_quantity
      flash[:warning] = "Quantity adjusted to available stock (#{@product.stock_quantity})."
    end

    session[:cart][product_id] = quantity
    flash[:notice] = "Cart updated." unless flash[:warning]

    redirect_to cart_path
  end

  # Feature 3.1.2
  def remove
    product_id = @product.id.to_s
    product_name = @product.name

    session[:cart].delete(product_id)
    flash[:notice] = "#{product_name} removed from cart."

    redirect_to cart_path
  end

  def clear
    session[:cart] = {}
    flash[:notice] = "Cart cleared."

    redirect_to cart_path
  end

  private

  # Initialize shopping cart session
  def initialize_cart
    session[:cart] ||= {}
  end

  def set_product
    @product = Product.find(params[:product_id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Product not found."
    redirect_to cart_path
  end

  # Load shopping cart product details
  def load_cart_items
    return [] if session[:cart].empty?

    items = []
    session[:cart].each do |product_id, quantity|
      product = Product.find_by(id: product_id)
      next unless product

      items << {
        product: product,
        quantity: quantity,
        subtotal: product.price * quantity
      }
    end
    items
  end

  # Calculate shopping cart total price
  def calculate_cart_total
    @cart_items.sum { |item| item[:subtotal] }
  end
end
