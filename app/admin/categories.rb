# ============================================
# app/admin/categories.rb (Feature 1.5)
# ============================================
ActiveAdmin.register Category do
  permit_params :name, :description

  index do
    selectable_column
    id_column
    column :name
    column :description
    column "Products Count" do |category|
      category.products.count
    end
    column :created_at
    actions
  end

  filter :name
  filter :created_at

  form do |f|
    f.inputs "Category Details" do
      f.input :name
      f.input :description, as: :text
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :description
      row "Products" do |category|
        category.products.map(&:name).join(", ")
      end
      row :created_at
      row :updated_at
    end

    panel "Products in this Category" do
      table_for category.products do
        column :id
        column :name
        column :price do |product|
          number_to_currency(product.price)
        end
        column :stock_quantity
      end
    end
  end
end
