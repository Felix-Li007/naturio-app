class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name, limit: 100, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :stock_quantity, default: 0
      t.boolean :on_sale, default: false
      t.boolean :is_new, default: true

      t.timestamps
    end
    add_index :products, :name
    add_index :products, :on_sale
    add_index :products, :is_new
  end
end
