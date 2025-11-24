class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :stripe_payment_id, limit: 255
      t.string :stripe_customer_id, limit: 255
      t.string :card_type, limit: 20
      t.string :card_last_four, limit: 4
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :status, limit: 20, default: 'pending'

      t.timestamps
    end
    add_index :payments, :stripe_payment_id
  end
end
