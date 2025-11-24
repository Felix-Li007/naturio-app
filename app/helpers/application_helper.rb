module ApplicationHelper
  # Category icons mapping
  def category_icon(category_name)
    icons = {
      "Organic Produce" => "apple",
      "Natural Supplements" => "capsule",
      "Gluten-Free Products" => "basket2",
      "Eco-Friendly Household" => "house-heart",
      "Health Beverages" => "cup-hot",
      "Organic Snacks" => "cookie"
    }
    icons[category_name] || "box"
  end

  # Flash message type to Bootstrap class
  def flash_class(type)
    case type.to_s
    when "notice", "success"
      "alert-success"
    when "alert", "error"
      "alert-danger"
    when "warning"
      "alert-warning"
    else
      "alert-info"
    end
  end

  # Active link helper
  def active_class(path)
    current_page?(path) ? "active" : ""
  end

  # Format price
  def format_price(price)
    number_to_currency(price)
  end

  # Calculate cart total
  def cart_total
    return 0 unless session[:cart].present?

    session[:cart].sum do |product_id, quantity|
      product = Product.find_by(id: product_id)
      product ? product.price * quantity : 0
    end
  end

  # Cart items count
  def cart_items_count
    return 0 unless session[:cart].present?
    session[:cart].values.sum
  end

  # Stock status badge
  def stock_badge(product)
    if product.stock_quantity > 10
      content_tag(:span, "In Stock", class: "badge bg-success")
    elsif product.stock_quantity > 0
      content_tag(:span, "Only #{product.stock_quantity} left", class: "badge bg-warning text-dark")
    else
      content_tag(:span, "Out of Stock", class: "badge bg-danger")
    end
  end

  # Order status badge
  def order_status_badge(status)
    classes = {
      "pending" => "bg-warning text-dark",
      "paid" => "bg-info",
      "shipped" => "bg-primary",
      "delivered" => "bg-success",
      "cancelled" => "bg-danger"
    }
    content_tag(:span, status.titleize, class: "badge #{classes[status] || 'bg-secondary'}")
  end

  # Tax display helper
  def display_tax(amount, label)
    return nil if amount.zero?
    "#{label}: #{number_to_currency(amount)}"
  end
end
