class Api::V1::OrdersController < Api::V1::BaseController
  before_action :set_order, only: [:show, :update, :destroy]
  
  # GET /api/v1/orders
  def index
    if user_signed_in?
      @orders = current_user.orders.includes(:line_items)
      render_success(@orders.as_json(include: { line_items: { include: :product } }))
    else
      render_error('Authentication required', :unauthorized)
    end
  end
  
  # GET /api/v1/orders/:id
  def show
    if user_signed_in? && (@order.user == current_user || current_user.admin?)
      render_success(@order.as_json(include: { line_items: { include: :product } }))
    else
      render_error('Access denied', :forbidden)
    end
  end
  
  # POST /api/v1/orders
  def create
    return unless user_signed_in?
    
    # Validate products exist before creating order
    line_items_params.each do |item_params|
      unless Product.where(id: item_params[:product_id]).exists?
        render_error('Invalid product specified', :unprocessable_entity)
        return
      end
    end
    
    @order = current_user.orders.build(order_params)
    @order.status = 'pending'
    calculated_total = calculate_total(line_items_params)
    @order.total = calculated_total
    @order.total_amount = calculated_total
    
    if @order.save
      create_line_items
      @order.reload # Reload to get updated total from line items
      @order.calculate_total! # Recalculate and save total after line items are created
      render_success(@order.as_json(include: { line_items: { include: :product } }), 'Order created successfully')
    else
      render_error(@order.errors.full_messages.join(', '))
    end
  rescue ActiveRecord::RecordInvalid => e
    render_error(e.message, :unprocessable_entity)
  end
  
  # PATCH/PUT /api/v1/orders/:id
  def update
    if user_signed_in? && (@order.user == current_user || current_user.admin?)
      if @order.update(order_params)
        render_success(@order.as_json(include: { line_items: { include: :product } }), 'Order updated successfully')
      else
        render_error(@order.errors.full_messages.join(', '))
      end
    else
      render_error('Access denied', :forbidden)
    end
  end
  
  # DELETE /api/v1/orders/:id
  def destroy
    if user_signed_in? && (@order.user == current_user || current_user.admin?)
      @order.destroy
      render_success(nil, 'Order deleted successfully')
    else
      render_error('Access denied', :forbidden)
    end
  end
  
  private
  
  def set_order
    @order = Order.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    render_error('Order not found', :not_found)
  end
  
  def order_params
    params.require(:order).permit(:status, :shipping_address, :billing_address)
  end
  
  def line_items_params
    params.require(:order).permit(line_items: [:product_id, :quantity, :price])[:line_items] || []
  end
  
  def calculate_total(items)
    total = 0
    items.each do |item|
      product = Product.find(item[:product_id])
      total += product.price * item[:quantity].to_i
    end
    total
  end
  
  def create_line_items
    line_items_params.each do |item_params|
      begin
        product = Product.find(item_params[:product_id])
        # Use BigDecimal for safe decimal handling
        price_value = BigDecimal(product.price.to_s)
        
        line_item = @order.line_items.build(
          quantity: item_params[:quantity],
          price: price_value
        )
        line_item.product = product
        line_item.save!(validate: false)
      rescue Mongoid::Errors::DocumentNotFound
        raise ActiveRecord::RecordInvalid.new(@order)
      end
    end
  end
  
  def action_requires_authentication?
    # All order operations require authentication
    true
  end
end
