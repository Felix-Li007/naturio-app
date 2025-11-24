# Feature 3.3.1 -Stripe Webhook processing
# Feature 3.2.2 -Order status automatically updated

class WebhooksController < ApplicationController
  # Skip CSRF validation (webhook from external)
  skip_before_action :verify_authenticity_token

  # POST /webhooks/stripe
  def stripe
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = Rails.configuration.stripe[:webhook_secret]

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      Rails.logger.error "Webhook JSON parse error: #{e.message}"
      render json: { error: "Invalid payload" }, status: :bad_request
      return
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "Webhook signature error: #{e.message}"
      render json: { error: "Invalid signature" }, status: :bad_request
      return
    end

    # Handle different event types
    case event.type
    when "checkout.session.completed"
      handle_checkout_session_completed(event.data.object)
    when "payment_intent.succeeded"
      handle_payment_intent_succeeded(event.data.object)
    when "payment_intent.payment_failed"
      handle_payment_failed(event.data.object)
    else
      Rails.logger.info "Unhandled event type: #{event.type}"
    end

    render json: { received: true }, status: :ok
  end

  private

  # Process Checkout Session completed
  def handle_checkout_session_completed(session)
    order_id = session.metadata&.order_id
    return unless order_id

    order = Order.find_by(id: order_id)
    return unless order

    Rails.logger.info "Processing checkout.session.completed for Order ##{order.id}"

    if session.payment_status == "paid" && order.pending?
      # Update order status (Feature 3.2.2)
      order.mark_as_paid!(session.payment_intent, session.id)

      # Create Payment record
      create_payment_from_session(order, session)

      Rails.logger.info "Order ##{order.id} marked as paid"
    end
  end

  # Process Payment Intent successfully
  def handle_payment_intent_succeeded(payment_intent)
    Rails.logger.info "Payment Intent succeeded: #{payment_intent.id}"

    # Find associated orders (via Payment or metadata)
    payment = Payment.find_by(stripe_payment_id: payment_intent.id)
    return unless payment

    payment.update!(status: "completed")
  end

  # Processing payment failed
  def handle_payment_failed(payment_intent)
    Rails.logger.error "Payment failed: #{payment_intent.id}"

    # You can send notification emails, etc. here
    order_id = payment_intent.metadata&.order_id
    return unless order_id

    order = Order.find_by(id: order_id)
    return unless order

    Rails.logger.error "Payment failed for Order ##{order.id}"
  end

  # Create Payment record from Session
  def create_payment_from_session(order, session)
    return if order.payment.present?

    begin
      # Get Payment Method details
      payment_intent = Stripe::PaymentIntent.retrieve(session.payment_intent)
      payment_method = Stripe::PaymentMethod.retrieve(payment_intent.payment_method)

      order.create_payment!(
        stripe_payment_id: session.payment_intent,
        stripe_customer_id: session.customer,
        amount: order.grand_total,
        status: "completed",
        card_type: payment_method.card&.brand,
        card_last_four: payment_method.card&.last4
      )
    rescue Stripe::StripeError => e
      Rails.logger.error "Error creating payment record: #{e.message}"
    end
  end
end
