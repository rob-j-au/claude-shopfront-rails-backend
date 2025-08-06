class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :update]

  def index
    @orders = current_user.orders.recent
  end

  def show
  end

  def create
    @order = current_user.orders.build
    
    # Add items from session cart
    if session[:cart] && session[:cart].any?
      begin
        line_items_built = 0
        session[:cart].each do |product_id, quantity|
          product = Product.find(product_id)
          next unless product && product.active? && quantity.to_i > 0
          
          line_item = @order.line_items.build(
            product: product, 
            quantity: quantity.to_i
          )
          line_items_built += 1
          Rails.logger.info "Built line item: Product #{product.name}, Quantity #{quantity}, Price #{product.price}"
        end
        
        Rails.logger.info "Built #{line_items_built} line items for order"
        
        if @order.line_items.any?
          if @order.save
            Rails.logger.info "Order saved successfully with #{@order.line_items.count} line items"
            # Recalculate and save the total after line items are saved
            @order.calculate_total!
            Rails.logger.info "Order total recalculated: #{@order.total_amount}"
            # Clear the cart after successful order
            session[:cart] = {}
            redirect_to @order, notice: 'Order placed successfully!'
          else
            Rails.logger.error "Order save failed: #{@order.errors.full_messages.join(', ')}"
            @order.line_items.each_with_index do |item, index|
              Rails.logger.error "Line item #{index} errors: #{item.errors.full_messages.join(', ')}" if item.errors.any?
            end
            redirect_to cart_path, alert: "Unable to place order: #{@order.errors.full_messages.join(', ')}"
          end
        else
          Rails.logger.error "No valid line items were built from cart"
          redirect_to cart_path, alert: 'Unable to place order. No valid items in cart.'
        end
      rescue => e
        Rails.logger.error "Order creation failed: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        redirect_to cart_path, alert: 'Unable to place order. Please try again.'
      end
    else
      redirect_to cart_path, alert: 'Your cart is empty.'
    end
  end

  def update
    action_type = params[:order][:action_type] if params[:order]
    Rails.logger.info "Order update requested - Order ID: #{@order.id}, Action Type: #{action_type}"
    Rails.logger.info "Order status: #{@order.status}, Can be cancelled: #{@order.can_be_cancelled?}"
    
    if action_type == 'cancel'
      if @order.can_be_cancelled?
        Rails.logger.info "Attempting to cancel order #{@order.order_number}"
        
        if @order.update(status: 'cancelled')
          Rails.logger.info "Order #{@order.order_number} cancelled successfully"
          redirect_to @order, notice: 'Order cancelled successfully.'
        else
          Rails.logger.error "Failed to cancel order #{@order.order_number}: #{@order.errors.full_messages.join(', ')}"
          redirect_to @order, alert: "Unable to cancel order: #{@order.errors.full_messages.join(', ')}"
        end
      else
        Rails.logger.warn "Order #{@order.order_number} cannot be cancelled - current status: #{@order.status}"
        redirect_to @order, alert: 'This order cannot be cancelled at this time.'
      end
    else
      Rails.logger.warn "Unknown action type: #{action_type}"
      redirect_to @order, alert: 'Invalid action requested.'
    end
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    redirect_to orders_path, alert: 'Order not found.'
  end
end
