ActiveAdmin.register Customer do
  permit_params :email, :username, :password, :password_confirmation

  # 禁止从 Admin 创建顾客（顾客自行注册）
  actions :index, :show, :edit, :update, :destroy

  index do
    selectable_column
    id_column
    column :email
    column :username
    column "Orders" do |customer|
      customer.orders.count
    end
    column "Total Spent" do |customer|
      number_to_currency(customer.orders.sum(:grand_total))
    end
    column :created_at
    actions
  end

  filter :email
  filter :username
  filter :created_at

  show do
    attributes_table do
      row :id
      row :email
      row :username
      row :created_at
      row :updated_at
    end

    panel "Addresses" do
      table_for customer.addresses do
        column :id
        column :address_type
        column :street_address
        column :city
        column :province do |addr|
          addr.province.code
        end
        column :postal_code
      end
    end

    # Feature 3.2.1 - 显示顾客所有订单及详情
    panel "Order History" do
      table_for customer.orders.recent do
        column :id do |order|
          link_to order.id, admin_order_path(order)
        end
        column :status do |order|
          status_tag order.status
        end
        column :subtotal do |order|
          number_to_currency(order.subtotal)
        end
        column "GST" do |order|
          number_to_currency(order.gst_amount)
        end
        column "PST" do |order|
          number_to_currency(order.pst_amount)
        end
        column "HST" do |order|
          number_to_currency(order.hst_amount)
        end
        column :grand_total do |order|
          number_to_currency(order.grand_total)
        end
        column :created_at
      end
    end
  end

  form do |f|
    f.inputs "Customer Details" do
      f.input :email
      f.input :username
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
