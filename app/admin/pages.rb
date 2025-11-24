# ============================================
# app/admin/pages.rb (Feature 1.4)
# 使用自定义表单，不是 scaffolded CRUD
# ============================================
ActiveAdmin.register Page do
  permit_params :title, :content

  # 禁用新建和删除，只允许编辑
  actions :index, :show, :edit, :update

  menu label: "Site Pages"

  index do
    id_column
    column :title
    column :slug
    column :updated_at
    actions defaults: false do |page|
      item "View", admin_page_path(page)
      item "Edit", edit_admin_page_path(page)
    end
  end

  # 自定义表单 - 不是 scaffolded CRUD
  form do |f|
    f.inputs "Page Content" do
      f.input :title
      # Slug 不可编辑
      f.input :slug, input_html: { disabled: true }
      f.input :content, as: :text,
              input_html: { rows: 20, class: "html-editor" },
              hint: "You can use HTML tags for formatting"
    end
    f.actions
  end

  show do
    attributes_table do
      row :title
      row :slug
      row :content do |page|
        page.content.html_safe
      end
      row :updated_at
    end
  end
end
