class CartController < ApplicationController
  def show
    @cart_items = []
    @total = 0
    
    if session[:cart]
      session[:cart].each do |product_id, quantity|
        product = Product.find(product_id)
        item_total = product.price * quantity
        @cart_items << { product: product, quantity: quantity, total: item_total }
        @total += item_total
      end
    end
  end

  def add
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i
    
    session[:cart] ||= {}
    session[:cart][product.id.to_s] = (session[:cart][product.id.to_s] || 0) + quantity
    
    redirect_to cart_path, notice: "#{product.name} added to cart!"
  end

  def update
    if params[:product_id] && params[:quantity]
      quantity = params[:quantity].to_i
      
      if quantity > 0
        session[:cart][params[:product_id]] = quantity
      else
        session[:cart].delete(params[:product_id])
      end
    end
    
    redirect_to cart_path
  end

  def remove
    session[:cart].delete(params[:product_id]) if session[:cart]
    redirect_to cart_path, notice: 'Item removed from cart.'
  end

  def clear
    session[:cart] = {}
    redirect_to cart_path, notice: 'Cart cleared.'
  end
end
