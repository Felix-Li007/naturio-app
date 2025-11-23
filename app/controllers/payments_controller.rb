# app/controllers/payments_controller.rb
# Feature 3.3.1 - Stripe 支付集成

class PaymentsController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_order, only: [:new, :create]

  # GET /payments/new?order_id=xxx
  # 显示支付页面
  def new
    unless @order.pending?
      redirect_to customers_order_path(@order), notice: 'This order has already been paid.'
      return
    end
  end

  # POST /payments
  # 创建 Stripe Checkout Session
  def create
    unless @order.pending?
      redirect_to customers_order_path(@order), alert: 'This order has already been paid.'
      return
    end

    begin
      # 创建 Stripe Checkout Session
      session = Stripe::Checkout::Session.create(
        payment_method_types: ['card'],
        customer_email: current_customer.email,
        line_items: build_line_items,
        mode: 'payment',
        success_url: success_payments_url(order_id: @order.id, session_id: '{CHECKOUT_SESSION_ID}'),
        cancel_url: cancel_payments_url(order_id: @order.id),
        metadata: {
          order_id: @order.id,
          customer_id: current_customer.id
        }
      )

      # 保存 Checkout Session ID 到订单
      @order.update!(stripe_checkout_id: session.id)

      # 重定向到 Stripe Checkout 页面
      redirect_to session.url, allow_other_host: true

    rescue Stripe::StripeError => e
      flash[:alert] = "Payment error: #{e.message}"
      redirect_to new_payment_path(order_id: @order.id)
    end
  end

  # GET /payments/success
  # 支付成功回调
  def success
    @order = current_customer.orders.find_by(id: params[:order_id])
    
    unless @order
      redirect_to root_path, alert: 'Order not found.'
      return
    end

    # 验证 Stripe Session
    if params[:session_id].present?
      begin
        session = Stripe::Checkout::Session.retrieve(params[:session_id])
        
        if session.payment_status == 'paid'
          # 更新订单状态 (Feature 3.2.2)
          @order.mark_as_paid!(session.payment_intent, session.id)
          
          # 创建 Payment 记录
          create_payment_record(session)
          
          flash[:notice] = 'Payment successful! Thank you for your order.'
        end
      rescue Stripe::StripeError => e
        Rails.logger.error "Stripe error: #{e.message}"
      end
    end
  end

  # GET /payments/cancel
  # 支付取消
  def cancel
    @order = current_customer.orders.find_by(id: params[:order_id])
    flash[:alert] = 'Payment was cancelled. You can try again or contact support.'
  end

  private

  def set_order
    @order = current_customer.orders.find_by(id: params[:order_id])
    
    unless @order
      redirect_to customers_orders_path, alert: 'Order not found.'
    end
  end

  # 构建 Stripe line_items
  def build_line_items
    items = @order.order_items.includes(:product).map do |item|
      {
        price_data: {
          currency: 'cad',
          product_data: {
            name: item.product.name,
            description: item.product.description.truncate(100)
          },
          unit_amount: (item.purchase_price * 100).to_i  # Stripe 使用分
        },
        quantity: item.quantity
      }
    end

    # 添加税费作为单独的行项目
    tax_total = @order.gst_amount + @order.pst_amount + @order.hst_amount
    if tax_total > 0
      items << {
        price_data: {
          currency: 'cad',
          product_data: {
            name: 'Tax (GST/PST/HST)'
          },
          unit_amount: (tax_total * 100).to_i
        },
        quantity: 1
      }
    end

    items
  end

  # 创建 Payment 记录 (Feature 3.3.1)
  def create_payment_record(session)
    return if @order.payment.present?

    # 获取 Payment Intent 详情
    payment_intent = Stripe::PaymentIntent.retrieve(session.payment_intent)
    payment_method = Stripe::PaymentMethod.retrieve(payment_intent.payment_method)

    @order.create_payment!(
      stripe_payment_id: session.payment_intent,
      stripe_customer_id: session.customer,
      amount: @order.grand_total,
      status: 'completed',
      card_type: payment_method.card&.brand,
      card_last_four: payment_method.card&.last4
    )
  rescue Stripe::StripeError => e
    Rails.logger.error "Error creating payment record: #{e.message}"
  end
end