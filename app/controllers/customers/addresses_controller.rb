# Feature 3.1.5
module Customers
  class AddressesController < ApplicationController
    before_action :authenticate_customer!
    before_action :set_address, only: [ :edit, :update, :destroy ]
    before_action :set_provinces, only: [ :new, :create, :edit, :update ]

    def index
      @addresses = current_customer.addresses.includes(:province)
    end

    def new
      @address = current_customer.addresses.build
    end

    def create
      @address = current_customer.addresses.build(address_params)

      if @address.save
        redirect_to customers_addresses_path,
                    notice: "Address was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @address.update(address_params)
        redirect_to customers_addresses_path,
                    notice: "Address was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @address.orders.any?
        redirect_to customers_addresses_path,
                    alert: "Cannot delete address with associated orders."
      else
        @address.destroy
        redirect_to customers_addresses_path,
                    notice: "Address was successfully deleted."
      end
    end

    private

    def set_address
      @address = current_customer.addresses.find(params[:id])
    end

    def set_provinces
      @provinces = Province.order(:name)
    end

    def address_params
      params.require(:address).permit(
        :street_address,
        :city,
        :province_id,
        :postal_code,
        :address_type
      )
    end
  end
end
