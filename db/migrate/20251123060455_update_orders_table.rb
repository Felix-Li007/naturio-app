class UpdateOrdersTable < ActiveRecord::Migration[8.1]
  def change
    # 移除 shipped_at 和 delivered_at
    add_column :orders, :shipped_at, :datetime unless column_exists?(:orders, :shipped_at)
    add_column :orders, :delivered_at, :datetime unless column_exists?(:orders, :delivered_at)

    # 添加 payment_at
    add_column :orders, :payment_at, :datetime unless column_exists?(:orders, :payment_at)
  end
end
