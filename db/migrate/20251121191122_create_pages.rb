class CreatePages < ActiveRecord::Migration[7.0]
  def change
    create_table :pages do |t|
      t.string :title, limit: 100, null: false
      t.string :slug, limit: 50, null: false
      t.text :content

      t.timestamps
    end
    add_index :pages, :slug, unique: true
  end
end
