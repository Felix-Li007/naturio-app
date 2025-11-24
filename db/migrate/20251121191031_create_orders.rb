class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :customer, null: false, foreign_key: true  # 改为 customer
      t.references :address, null: false, foreign_key: true
      t.string :status, limit: 20, default: 'pending'
      t.decimal :subtotal, precision: 10, scale: 2, default: 0
      t.decimal :gst_amount, precision: 10, scale: 2, default: 0
      t.decimal :pst_amount, precision: 10, scale: 2, default: 0
      t.decimal :hst_amount, precision: 10, scale: 2, default: 0
      t.decimal :grand_total, precision: 10, scale: 2, default: 0
      t.string :stripe_payment_id, limit: 255
      t.datetime :shipped_at
      t.datetime :delivered_at

      t.timestamps
    end

    add_index :orders, :status
    add_index :orders, :stripe_payment_id
  end
end
