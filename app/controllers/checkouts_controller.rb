# app/controllers/checkouts_controller.rb
# Feature 3.1.3 ✯ - 完整结账流程
# Feature 3.2.3 - 省份税率计算
# Feature 3.3.2 - 历史价格保护

class CheckoutsController < ApplicationController
  before_action :authenticate_customer!
  before_action :ensure_cart_not_empty
  before_action :load_cart_items

  # GET /checkout
  # Step 1: 选择/确认地址
  def show
    @addresses = current_customer.addresses.includes(:province)
    @selected_address = current_customer.primary_address

    # 如果没有地址，跳转到添加地址
    if @addresses.empty?
      redirect_to address_checkouts_path
    end
  end

  # GET /checkout/address
  # 添加新地址（如果没有保存的地址）
  def address
    @address = current_customer.addresses.build
    @provinces = Province.order(:name)
  end

  # POST /checkout/address
  # 保存新地址
  def save_address
    @address = current_customer.addresses.build(address_params)
    @provinces = Province.order(:name)

    if @address.save
      redirect_to checkouts_path, notice: "Address saved successfully."
    else
      render :address, status: :unprocessable_entity
    end
  end

  # GET /checkout/review
  # Step 2: 订单预览 + 税费计算 (Feature 3.2.3)
  def review
    @address = current_customer.addresses.find_by(id: params[:address_id])

    unless @address
      redirect_to checkout_path, alert: "Please select a shipping address."
      return
    end

    # 保存选中的地址到 session
    session[:checkout_address_id] = @address.id

    # 计算税费 (Feature 3.2.3)
    calculate_totals(@address.province)
  end

  # POST /checkout
  # Step 3: 创建订单 (Feature 3.1.3, 3.3.2)
  def create
    @address = current_customer.addresses.find_by(id: session[:checkout_address_id])

    unless @address
      redirect_to checkout_path, alert: "Please select a shipping address."
      return
    end

    # 计算税费
    calculate_totals(@address.province)

    # 创建订单
    @order = build_order(@address)

    ActiveRecord::Base.transaction do
      @order.save!

      # 创建订单项目，保存购买时价格 (Feature 3.3.2)
      create_order_items(@order)

      # 更新订单总计
      @order.update!(
        subtotal: @subtotal,
        gst_amount: @gst_amount,
        pst_amount: @pst_amount,
        hst_amount: @hst_amount,
        grand_total: @grand_total
      )

      # 减少库存
      update_stock
      session.delete(:checkout_address_id)
    end

    # 保存订单ID用于确认页面
    session[:last_order_id] = @order.id

    redirect_to confirmation_checkouts_path

  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = "Error creating order: #{e.message}"
    redirect_to checkouts_path
  end

  # GET /checkout/confirmation
  # Step 4: 订单确认
  def confirmation
    @order = current_customer.orders.find_by(id: session[:last_order_id])

    unless @order
      redirect_to root_path, alert: "Order not found."
      return
    end

    @order_items = @order.order_items.includes(:product)
    session[:cart] = {}
    session.delete(:last_order_id)
  end

  private

  def ensure_cart_not_empty
    if session[:cart].blank? || session[:cart].empty?
      redirect_to cart_path, alert: "Your cart is empty."
    end
  end

  def load_cart_items
    @cart_items = []
    return if session[:cart].blank?

    session[:cart].each do |product_id, quantity|
      product = Product.find_by(id: product_id)
      next unless product

      @cart_items << {
        product: product,
        quantity: quantity,
        subtotal: product.price * quantity
      }
    end
  end

  # Feature 3.2.3 - 省份税率计算
  def calculate_totals(province)
    @subtotal = @cart_items.sum { |item| item[:subtotal] }

    @gst_amount = @subtotal * (province.gst_rate / 100)
    @pst_amount = @subtotal * (province.pst_rate / 100)
    @hst_amount = @subtotal * (province.hst_rate / 100)
    @tax_total = @gst_amount + @pst_amount + @hst_amount

    @grand_total = @subtotal + @tax_total
  end

  def build_order(address)
    current_customer.orders.build(
      address: address,
      status: "pending",
      subtotal: 0,
      gst_amount: 0,
      pst_amount: 0,
      hst_amount: 0,
      grand_total: 0
    )
  end

  # Feature 3.3.2 - 保存购买时价格
  def create_order_items(order)
    @cart_items.each do |item|
      order.order_items.create!(
        product: item[:product],
        quantity: item[:quantity],
        purchase_price: item[:product].price,  # 保存当前价格
        subtotal: item[:subtotal]
      )
    end
  end

  def update_stock
    @cart_items.each do |item|
      product = item[:product]
      new_quantity = product.stock_quantity - item[:quantity]
      product.update!(stock_quantity: [ new_quantity, 0 ].max)
    end
  end

  def address_params
    params.require(:address).permit(
      :street_address, :city, :province_id, :postal_code, :address_type
    )
  end
end
