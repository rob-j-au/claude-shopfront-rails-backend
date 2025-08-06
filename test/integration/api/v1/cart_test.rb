require 'test_helper'

class Api::V1::CartTest < ActionDispatch::IntegrationTest
  def setup
    @product1 = Product.create!(
      name: 'Test Product 1',
      description: 'First test product',
      price: 29.99,
      stock_quantity: 100,
      category: 'Electronics',
      sku: "TEST-CART-#{Time.now.to_i}-#{rand(10000)}-001"
    )
    
    @product2 = Product.create!(
      name: 'Test Product 2',
      description: 'Second test product',
      price: 19.99,
      stock_quantity: 50,
      category: 'Books',
      sku: "TEST-CART-#{Time.now.to_i}-#{rand(10000)}-002"
    )
    
    @out_of_stock_product = Product.create!(
      name: 'Out of Stock Product',
      description: 'Product with no stock',
      price: 39.99,
      stock_quantity: 0,
      category: 'Clothing',
      sku: "TEST-CART-#{Time.now.to_i}-#{rand(10000)}-003"
    )
  end

  def teardown
    Product.delete_all
  end

  test "should show empty cart" do
    get "/api/v1/cart"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('data')
    assert_equal [], json_response['data']['items']
    assert_equal 0, json_response['data']['total']
    assert_equal 0, json_response['data']['item_count']
  end

  test "should add item to cart" do
    post "/api/v1/cart/add", params: {
      product_id: @product1.id.to_s,
      quantity: 2
    }, as: :json
    
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('message')
    assert_includes json_response['message'], @product1.name
    
    # Verify item was added to cart
    get "/api/v1/cart"
    assert_response :success
    
    cart_response = JSON.parse(response.body)
    assert_equal 1, cart_response['data']['items'].length
    assert_equal @product1.name, cart_response['data']['items'][0]['product']['name']
    assert_equal 2, cart_response['data']['items'][0]['quantity']
    assert_equal 59.98, cart_response['data']['items'][0]['total']
    assert_equal 59.98, cart_response['data']['total']
    assert_equal 2, cart_response['data']['item_count']
  end

  test "should not add item with zero quantity" do
    post "/api/v1/cart/add", params: {
      product_id: @product1.id.to_s,
      quantity: 0
    }, as: :json
    
    assert_response :unprocessable_entity
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
    assert_equal 'Quantity must be greater than 0', json_response['error']
  end

  test "should not add item with quantity exceeding stock" do
    post "/api/v1/cart/add", params: {
      product_id: @product1.id.to_s,
      quantity: 150
    }, as: :json
    
    assert_response :unprocessable_entity
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
    assert_equal 'Not enough stock available', json_response['error']
  end

  test "should not add non-existent product" do
    post "/api/v1/cart/add", params: {
      product_id: 'nonexistent',
      quantity: 1
    }, as: :json
    
    assert_response :not_found
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
    assert_equal 'Product not found', json_response['error']
  end

  test "should add multiple different items to cart" do
    # Add first product
    post "/api/v1/cart/add", params: {
      product_id: @product1.id.to_s,
      quantity: 1
    }, as: :json
    assert_response :success
    
    # Add second product
    post "/api/v1/cart/add", params: {
      product_id: @product2.id.to_s,
      quantity: 3
    }, as: :json
    assert_response :success
    
    # Verify cart contents
    get "/api/v1/cart"
    assert_response :success
    
    cart_response = JSON.parse(response.body)
    assert_equal 2, cart_response['data']['items'].length
    assert_equal 89.96, cart_response['data']['total'] # 29.99 + (19.99 * 3)
    assert_equal 4, cart_response['data']['item_count'] # 1 + 3
  end

  test "should update cart item quantity" do
    # Add item to cart first
    post "/api/v1/cart/add", params: {
      product_id: @product1.id.to_s,
      quantity: 1
    }, as: :json
    assert_response :success
    
    # Update quantity
    patch "/api/v1/cart/update", params: {
      product_id: @product1.id.to_s,
      quantity: 3
    }, as: :json
    
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('message')
    assert_equal 'Cart updated successfully', json_response['message']
    
    # Verify updated quantity
    get "/api/v1/cart"
    assert_response :success
    
    cart_response = JSON.parse(response.body)
    assert_equal 1, cart_response['data']['items'].length
    assert_equal 3, cart_response['data']['items'][0]['quantity']
    assert_equal 89.97, cart_response['data']['items'][0]['total']
  end

  test "should remove item when updating quantity to zero" do
    # Add item to cart first
    post "/api/v1/cart/add", params: {
      product_id: @product1.id.to_s,
      quantity: 2
    }, as: :json
    assert_response :success
    
    # Update quantity to zero
    patch "/api/v1/cart/update", params: {
      product_id: @product1.id.to_s,
      quantity: 0
    }, as: :json
    
    assert_response :success
    
    # Verify item was removed
    get "/api/v1/cart"
    assert_response :success
    
    cart_response = JSON.parse(response.body)
    assert_equal 0, cart_response['data']['items'].length
    assert_equal 0, cart_response['data']['total']
  end

  test "should not update cart without required parameters" do
    patch "/api/v1/cart/update", params: {
      quantity: 3
    }, as: :json
    
    assert_response :unprocessable_entity
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
    assert_equal 'Product ID and quantity are required', json_response['error']
  end

  test "should not update cart with quantity exceeding stock" do
    # Add item to cart first
    post "/api/v1/cart/add", params: {
      product_id: @product2.id.to_s,
      quantity: 1
    }, as: :json
    assert_response :success
    
    # Try to update to quantity exceeding stock
    patch "/api/v1/cart/update", params: {
      product_id: @product2.id.to_s,
      quantity: 100
    }, as: :json
    
    assert_response :unprocessable_entity
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
    assert_equal 'Not enough stock available', json_response['error']
  end

  test "should remove specific item from cart" do
    # Add multiple items to cart
    post "/api/v1/cart/add", params: {
      product_id: @product1.id.to_s,
      quantity: 1
    }, as: :json
    assert_response :success
    
    post "/api/v1/cart/add", params: {
      product_id: @product2.id.to_s,
      quantity: 2
    }, as: :json
    assert_response :success
    
    # Remove one specific item
    delete "/api/v1/cart/remove", params: {
      product_id: @product1.id.to_s
    }, as: :json
    
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('message')
    assert_equal 'Item removed from cart', json_response['message']
    
    # Verify only one item remains
    get "/api/v1/cart"
    assert_response :success
    
    cart_response = JSON.parse(response.body)
    assert_equal 1, cart_response['data']['items'].length
    assert_equal @product2.name, cart_response['data']['items'][0]['product']['name']
  end

  test "should not remove item without product_id" do
    delete "/api/v1/cart/remove", as: :json
    
    assert_response :unprocessable_entity
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
    assert_equal 'Product ID is required', json_response['error']
  end

  test "should clear entire cart" do
    # Add multiple items to cart
    post "/api/v1/cart/add", params: {
      product_id: @product1.id.to_s,
      quantity: 2
    }, as: :json
    assert_response :success
    
    post "/api/v1/cart/add", params: {
      product_id: @product2.id.to_s,
      quantity: 1
    }, as: :json
    assert_response :success
    
    # Clear cart
    delete "/api/v1/cart/clear"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('message')
    assert_equal 'Cart cleared', json_response['message']
    
    # Verify cart is empty
    get "/api/v1/cart"
    assert_response :success
    
    cart_response = JSON.parse(response.body)
    assert_equal 0, cart_response['data']['items'].length
    assert_equal 0, cart_response['data']['total']
    assert_equal 0, cart_response['data']['item_count']
  end

  test "should handle invalid products in session gracefully" do
    # Manually add invalid product ID to session
    post "/api/v1/cart/add", params: {
      product_id: @product1.id.to_s,
      quantity: 1
    }, as: :json
    assert_response :success
    
    # Delete the product to simulate invalid reference
    @product1.delete
    
    # Cart should handle this gracefully and remove invalid items
    get "/api/v1/cart"
    assert_response :success
    
    cart_response = JSON.parse(response.body)
    assert_equal 0, cart_response['data']['items'].length
    assert_equal 0, cart_response['data']['total']
  end
end
