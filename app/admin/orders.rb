ActiveAdmin.register Order do
  permit_params :status

  actions :index, :show, :edit, :update

  index do
    selectable_column
    id_column
    column :customer do |order|
      link_to order.customer.username, admin_customer_path(order.customer)
    end
    column :status do |order|
      status_tag order.status, class: order_status_class(order.status)
    end
    column :subtotal do |order|
      number_to_currency(order.subtotal)
    end
    column "Taxes" do |order|
      number_to_currency(order.gst_amount + order.pst_amount + order.hst_amount)
    end
    column :grand_total do |order|
      number_to_currency(order.grand_total)
    end
    column :created_at
    actions
  end

  filter :customer, as: :select, collection: -> { Customer.pluck(:username, :id) }
  filter :status, as: :select, collection: %w[pending paid shipped delivered cancelled]
  filter :created_at
  filter :grand_total

  # Feature 3.2.1 - 显示完整订单详情
  show do
    attributes_table do
      row :id
      row :customer do |order|
        link_to order.customer.username, admin_customer_path(order.customer)
      end
      row "Shipping Address" do |order|
        order.address.full_address
      end
      row :status do |order|
        status_tag order.status, class: order_status_class(order.status)
      end
    end

    panel "Order Items" do
      table_for order.order_items do
        column :product do |item|
          link_to item.product.name, admin_product_path(item.product)
        end
        column :quantity
        column "Unit Price" do |item|
          number_to_currency(item.purchase_price)
        end
        column :subtotal do |item|
          number_to_currency(item.subtotal)
        end
      end
    end

    panel "Order Totals" do
      attributes_table_for order do
        row :subtotal do |o|
          number_to_currency(o.subtotal)
        end
        row "GST" do |o|
          number_to_currency(o.gst_amount)
        end
        row "PST" do |o|
          number_to_currency(o.pst_amount)
        end
        row "HST" do |o|
          number_to_currency(o.hst_amount)
        end
        row :grand_total do |o|
          number_to_currency(o.grand_total)
        end
      end
    end

    panel "Payment & Shipping" do
      attributes_table_for order do
        row :stripe_payment_id
        row :shipped_at
        row :payment_at
        row :delivered_at
        row :created_at
      end
    end
  end

  form do |f|
    f.inputs "Update Order Status" do
      f.input :status, as: :select,
              collection: %w[pending paid shipped delivered cancelled],
              include_blank: false
    end
    f.actions
  end

  # Feature 3.2.2 - 快速状态更新操作
  member_action :mark_shipped, method: :put do
    resource.mark_as_shipped!
    redirect_to admin_order_path(resource), notice: "Order marked as shipped!"
  end

  member_action :mark_delivered, method: :put do
    resource.update!(status: "delivered", delivered_at: Time.current)
    redirect_to admin_order_path(resource), notice: "Order marked as delivered!"
  end

  action_item :mark_shipped, only: :show, if: proc { resource.paid? } do
    link_to "Mark as Shipped", mark_shipped_admin_order_path(resource), method: :put
  end

  action_item :mark_delivered, only: :show, if: proc { resource.shipped? } do
    link_to "Mark as Delivered", mark_delivered_admin_order_path(resource), method: :put
  end
end
