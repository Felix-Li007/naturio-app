class CreateProvinces < ActiveRecord::Migration[7.0]
  def change
    create_table :provinces do |t|
      t.string :name, limit: 50, null: false
      t.string :code, limit: 2, null: false
      t.decimal :gst_rate, precision: 5, scale: 2, default: 0
      t.decimal :pst_rate, precision: 5, scale: 2, default: 0
      t.decimal :hst_rate, precision: 5, scale: 2, default: 0

      t.timestamps
    end
    add_index :provinces, :code, unique: true
    add_index :provinces, :name, unique: true
  end
end
