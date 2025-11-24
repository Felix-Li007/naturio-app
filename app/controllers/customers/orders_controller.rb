# Feature 3.2.1
module Customers
  class OrdersController < ApplicationController
    before_action :authenticate_customer!
    before_action :set_order, only: [ :show ]

    def index
      @orders = current_customer.orders.includes(:order_items, :address).order(created_at: :desc).page(params[:page]).per(10)
    end

    def show
      @order_items = @order.order_items.includes(:product)
    end

    private

    def set_order
      @order = current_customer.orders.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to customers_orders_path, alert: "Order not found."
    end
  end
end
