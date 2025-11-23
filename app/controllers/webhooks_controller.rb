# app/controllers/webhooks_controller.rb
# Feature 3.3.1 - Stripe Webhook 处理
# Feature 3.2.2 - 订单状态自动更新

class WebhooksController < ApplicationController
  # 跳过 CSRF 验证（Webhook 来自外部）
  skip_before_action :verify_authenticity_token

  # POST /webhooks/stripe
  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.configuration.stripe[:webhook_secret]

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      Rails.logger.error "Webhook JSON parse error: #{e.message}"
      render json: { error: 'Invalid payload' }, status: :bad_request
      return
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "Webhook signature error: #{e.message}"
      render json: { error: 'Invalid signature' }, status: :bad_request
      return
    end

    # 处理不同的事件类型
    case event.type
    when 'checkout.session.completed'
      handle_checkout_session_completed(event.data.object)
    when 'payment_intent.succeeded'
      handle_payment_intent_succeeded(event.data.object)
    when 'payment_intent.payment_failed'
      handle_payment_failed(event.data.object)
    else
      Rails.logger.info "Unhandled event type: #{event.type}"
    end

    render json: { received: true }, status: :ok
  end

  private

  # 处理 Checkout Session 完成
  def handle_checkout_session_completed(session)
    order_id = session.metadata&.order_id
    return unless order_id

    order = Order.find_by(id: order_id)
    return unless order

    Rails.logger.info "Processing checkout.session.completed for Order ##{order.id}"

    if session.payment_status == 'paid' && order.pending?
      # 更新订单状态 (Feature 3.2.2)
      order.mark_as_paid!(session.payment_intent, session.id)
      
      # 创建 Payment 记录
      create_payment_from_session(order, session)
      
      Rails.logger.info "Order ##{order.id} marked as paid"
    end
  end

  # 处理 Payment Intent 成功
  def handle_payment_intent_succeeded(payment_intent)
    Rails.logger.info "Payment Intent succeeded: #{payment_intent.id}"
    
    # 查找关联的订单（通过 Payment 或 metadata）
    payment = Payment.find_by(stripe_payment_id: payment_intent.id)
    return unless payment

    payment.update!(status: 'completed')
  end

  # 处理支付失败
  def handle_payment_failed(payment_intent)
    Rails.logger.error "Payment failed: #{payment_intent.id}"
    
    # 可以在这里发送通知邮件等
    order_id = payment_intent.metadata&.order_id
    return unless order_id

    order = Order.find_by(id: order_id)
    return unless order

    # 记录失败信息（可选）
    Rails.logger.error "Payment failed for Order ##{order.id}"
  end

  # 从 Session 创建 Payment 记录
  def create_payment_from_session(order, session)
    return if order.payment.present?

    begin
      # 获取 Payment Method 详情
      payment_intent = Stripe::PaymentIntent.retrieve(session.payment_intent)
      payment_method = Stripe::PaymentMethod.retrieve(payment_intent.payment_method)

      order.create_payment!(
        stripe_payment_id: session.payment_intent,
        stripe_customer_id: session.customer,
        amount: order.grand_total,
        status: 'completed',
        card_type: payment_method.card&.brand,
        card_last_four: payment_method.card&.last4
      )
    rescue Stripe::StripeError => e
      Rails.logger.error "Error creating payment record: #{e.message}"
    end
  end
end