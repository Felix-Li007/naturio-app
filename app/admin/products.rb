# ============================================
# app/admin/products.rb (Feature 1.2, 1.3)
# ============================================
ActiveAdmin.register Product do
  permit_params :name, :description, :price, :stock_quantity,
                :on_sale, :is_new, :image, category_ids: []

  # 列表页面
  index do
    selectable_column
    id_column
    column :name
    column :price do |product|
      number_to_currency(product.price)
    end
    column :stock_quantity
    column :on_sale
    column :is_new
    column :categories do |product|
      product.categories.map(&:name).join(", ")
    end
    column :image do |product|
      if product.image.attached?
        image_tag url_for(product.image), width: 50
      end
    end
    column :updated_at
    actions
  end

  # 筛选器
  filter :name
  filter :categories
  filter :price
  filter :on_sale
  filter :is_new
  filter :stock_quantity
  filter :created_at
  filter :updated_at

  # 表单 (Feature 4.2.5 - Many-to-Many 在 Admin 管理)
  form do |f|
    f.inputs "Product Details" do
      f.input :name
      f.input :description, as: :text
      f.input :price
      f.input :stock_quantity
      f.input :on_sale
      f.input :is_new
    end

    f.inputs "Categories" do
      f.input :categories,
              as: :check_boxes,
              collection: Category.alphabetical
    end

    f.inputs "Product Image" do
      f.input :image, as: :file
      if f.object.image.attached?
        image_tag url_for(f.object.image), width: 200
      end
    end

    f.actions
  end

  # 详情页面
  show do
    attributes_table do
      row :id
      row :name
      row :description
      row :price do |product|
        number_to_currency(product.price)
      end
      row :stock_quantity
      row :on_sale
      row :is_new
      row :categories do |product|
        product.categories.map(&:name).join(", ")
      end
      row :image do |product|
        if product.image.attached?
          image_tag url_for(product.image), width: 200
        end
      end
      row :created_at
      row :updated_at
    end
  end
end
