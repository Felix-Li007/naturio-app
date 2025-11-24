class AddStripeFieldsToOrders < ActiveRecord::Migration[8.1]
  def change
    # 添加其他字段stripe_checkout_id,用于重新支付
    add_column :orders, :stripe_checkout_id, :string unless column_exists?(:orders, :stripe_checkout_id)

    add_index :orders, :stripe_checkout_id unless index_exists?(:orders, :stripe_checkout_id)
  end
end
