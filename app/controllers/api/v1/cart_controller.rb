class Api::V1::CartController < Api::V1::BaseController
  # GET /api/v1/cart
  def show
    cart_items = []
    total = 0
    
    if session[:cart]
      session[:cart].each do |product_id, quantity|
        begin
          product = Product.find(product_id)
          item_total = product.price * quantity
          cart_items << {
            product: product.as_json(include_methods: [:formatted_price]),
            quantity: quantity,
            total: item_total
          }
          total += item_total
        rescue Mongoid::Errors::DocumentNotFound
          # Remove invalid product from cart
          session[:cart].delete(product_id)
        end
      end
    end
    
    render_success({
      items: cart_items,
      total: total,
      item_count: cart_items.sum { |item| item[:quantity] }
    })
  end
  
  # POST /api/v1/cart/add
  def add
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i
    
    if quantity <= 0
      render_error('Quantity must be greater than 0')
      return
    end
    
    if quantity > product.stock_quantity
      render_error('Not enough stock available')
      return
    end
    
    session[:cart] ||= {}
    session[:cart][product.id.to_s] = (session[:cart][product.id.to_s] || 0) + quantity
    
    render_success(nil, "#{product.name} added to cart!")
  rescue Mongoid::Errors::DocumentNotFound
    render_error('Product not found', :not_found)
  end
  
  # PATCH /api/v1/cart/update
  def update
    unless params[:product_id] && params[:quantity]
      render_error('Product ID and quantity are required')
      return
    end
    
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i
    
    session[:cart] ||= {}
    
    if quantity > 0
      if quantity > product.stock_quantity
        render_error('Not enough stock available')
        return
      end
      session[:cart][params[:product_id]] = quantity
    else
      session[:cart].delete(params[:product_id])
    end
    
    render_success(nil, 'Cart updated successfully')
  rescue Mongoid::Errors::DocumentNotFound
    render_error('Product not found', :not_found)
  end
  
  # DELETE /api/v1/cart/remove
  def remove
    unless params[:product_id]
      render_error('Product ID is required')
      return
    end
    
    session[:cart]&.delete(params[:product_id])
    render_success(nil, 'Item removed from cart')
  end
  
  # DELETE /api/v1/cart/clear
  def clear
    session[:cart] = {}
    render_success(nil, 'Cart cleared')
  end
  
  private
  
  def action_requires_authentication?
    # Cart operations don't require authentication (session-based)
    false
  end
end
