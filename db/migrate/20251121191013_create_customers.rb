class CreateCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :customers do |t|
      ## Database authenticatable (Devise)
      t.string :email,              null: false, limit: 50
      t.string :encrypted_password, null: false, limit: 255

      ## Custom field (根据 ERD)
      t.string :username,           limit: 50

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      t.timestamps null: false
    end

    add_index :customers, :email,                unique: true
    add_index :customers, :username,             unique: true
    add_index :customers, :reset_password_token, unique: true
  end
end
