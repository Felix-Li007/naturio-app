class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.references :customer, null: false, foreign_key: true  # 改为 customer
      t.references :province, null: false, foreign_key: true
      t.string :street_address, limit: 255, null: false
      t.string :city, limit: 100, null: false
      t.string :postal_code, limit: 10, null: false
      t.string :address_type, limit: 20, default: 'shipping'

      t.timestamps
    end
  end
end
