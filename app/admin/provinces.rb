# ============================================
# app/admin/provinces.rb (Feature 3.2.3)
# ============================================
ActiveAdmin.register Province do
  permit_params :name, :code, :gst_rate, :pst_rate, :hst_rate

  index do
    selectable_column
    id_column
    column :name
    column :code
    column :gst_rate do |p|
      "#{p.gst_rate}%"
    end
    column :pst_rate do |p|
      "#{p.pst_rate}%"
    end
    column :hst_rate do |p|
      "#{p.hst_rate}%"
    end
    column "Total Tax" do |p|
      "#{p.total_tax_rate}%"
    end
    actions
  end

  filter :name
  filter :code

  form do |f|
    f.inputs "Province Details" do
      f.input :name
      f.input :code, hint: "Two-letter code (e.g., MB, ON)"
    end
    f.inputs "Tax Rates" do
      f.input :gst_rate, hint: "GST percentage"
      f.input :pst_rate, hint: "PST percentage"
      f.input :hst_rate, hint: "HST percentage"
    end
    f.actions
  end
end
