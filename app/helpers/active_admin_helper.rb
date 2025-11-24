module ActiveAdminHelper
  def order_status_class(status)
    case status
    when "pending" then "warning"
    when "paid" then "yes"
    when "shipped" then "yes"
    when "delivered" then "yes"
    when "cancelled" then "error"
    else "default"
    end
  end
end
