require 'test_helper'

class Api::V1::OrdersTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      first_name: 'Test',
      last_name: 'User',
      email: "test#{Time.now.to_i}#{rand(1000)}@example.com",
      password: 'password123',
      password_confirmation: 'password123'
    )
    
    @other_user = User.create!(
      first_name: 'Other',
      last_name: 'User',
      email: "other#{Time.now.to_i}#{rand(1000)}@example.com",
      password: 'password123',
      password_confirmation: 'password123'
    )
    
    @product1 = Product.create!(
      name: 'Test Product 1',
      description: 'First test product',
      price: 29.99,
      stock_quantity: 100,
      category: 'Electronics',
      sku: "TEST-ORDER-#{Time.now.to_i}-#{rand(10000)}-001"
    )
    
    @product2 = Product.create!(
      name: 'Test Product 2',
      description: 'Second test product',
      price: 19.99,
      stock_quantity: 50,
      category: 'Books',
      sku: "TEST-ORDER-#{Time.now.to_i}-#{rand(10000)}-002"
    )
    
    @order = @user.orders.create!(
      status: 'pending',
      total_amount: 49.98,
      order_number: "TEST-ORDER-#{Time.now.to_i}-#{rand(10000)}",
      shipping_address: '123 Test St, Test City, TC 12345',
      billing_address: '123 Test St, Test City, TC 12345'
    )
    
    line_item1 = @order.line_items.build(
      quantity: 1,
      price: 29.99
    )
    line_item1.product = @product1
    line_item1.save!(validate: false)
    
    line_item2 = @order.line_items.build(
      quantity: 1,
      price: 19.99
    )
    line_item2.product = @product2
    line_item2.save!(validate: false)
    
    # Recalculate total after line items are created
    @order.calculate_total!
  end

  def teardown
    User.delete_all
    Product.delete_all
    Order.delete_all
  end

  test "should get user orders when authenticated" do
    sign_in @user
    
    get "/api/v1/orders"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('data')
    assert_equal 1, json_response['data'].length
    
    order_data = json_response['data'][0]
    assert_equal @order.id.to_s, order_data['_id']
    assert_equal 'pending', order_data['status']
    assert_equal "49.98", order_data['total']
    assert order_data.has_key?('line_items')
    assert_equal 2, order_data['line_items'].length
  end

  test "should not get orders without authentication" do
    get "/api/v1/orders"
    assert_response :unauthorized
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
    assert_equal "You need to sign in or sign up before continuing.", json_response['error']
  end

  test "should show specific order when authenticated and authorized" do
    sign_in @user
    
    get "/api/v1/orders/#{@order.id}"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('data')
    
    order_data = json_response['data']
    assert_equal @order.id.to_s, order_data['_id']
    assert_equal 'pending', order_data['status']
    assert_equal "49.98", order_data['total']
    assert order_data.has_key?('line_items')
    assert_equal 2, order_data['line_items'].length
  end

  test "should not show order without authentication" do
    get "/api/v1/orders/#{@order.id}"
    assert_response :unauthorized
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
    assert_equal "You need to sign in or sign up before continuing.", json_response['error']
  end

  test "should not show other user's order" do
    sign_in @other_user
    
    get "/api/v1/orders/#{@order.id}"
    assert_response :forbidden
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
    assert_equal 'Access denied', json_response['error']
  end

  test "should return 404 for non-existent order" do
    sign_in @user
    
    get "/api/v1/orders/nonexistent"
    assert_response :not_found
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
    assert_equal 'Order not found', json_response['error']
  end

  test "should create order when authenticated" do
    sign_in @user
    
    order_params = {
      order: {
        shipping_address: '456 New St, New City, NC 67890',
        billing_address: '456 New St, New City, NC 67890',
        line_items: [
          {
            product_id: @product1.id.to_s,
            quantity: 2
          },
          {
            product_id: @product2.id.to_s,
            quantity: 1
          }
        ]
      }
    }
    
    post "/api/v1/orders", params: order_params, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('data')
    assert json_response.has_key?('message')
    assert_equal 'Order created successfully', json_response['message']
    
    order_data = json_response['data']
    assert_equal 'pending', order_data['status']
    assert_equal "79.97", order_data['total'] # (29.99 * 2) + (19.99 * 1)
    assert_equal '456 New St, New City, NC 67890', order_data['shipping_address']
    assert order_data.has_key?('line_items')
    assert_equal 2, order_data['line_items'].length
  end

  test "should not create order without authentication" do
    order_params = {
      order: {
        shipping_address: '456 New St, New City, NC 67890',
        billing_address: '456 New St, New City, NC 67890',
        line_items: [
          {
            product_id: @product1.id.to_s,
            quantity: 1
          }
        ]
      }
    }
    
    post "/api/v1/orders", params: order_params, as: :json
    assert_response :unauthorized
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
    assert_equal "You need to sign in or sign up before continuing.", json_response['error']
  end

  test "should not create order with invalid product" do
    sign_in @user
    
    order_params = {
      order: {
        shipping_address: '456 New St, New City, NC 67890',
        billing_address: '456 New St, New City, NC 67890',
        line_items: [
          {
            product_id: 'nonexistent',
            quantity: 1
          }
        ]
      }
    }
    
    post "/api/v1/orders", params: order_params, as: :json
    assert_response :unprocessable_entity
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
  end

  test "should update order status when authenticated and authorized" do
    sign_in @user
    
    update_params = {
      order: {
        status: 'shipped'
      }
    }
    
    put "/api/v1/orders/#{@order.id}", params: update_params, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('data')
    assert json_response.has_key?('message')
    assert_equal 'Order updated successfully', json_response['message']
    assert_equal 'shipped', json_response['data']['status']
  end

  test "should not update order without authentication" do
    update_params = {
      order: {
        status: 'shipped'
      }
    }
    
    put "/api/v1/orders/#{@order.id}", params: update_params, as: :json
    assert_response :unauthorized
  end

  test "should not update other user's order" do
    sign_in @other_user
    
    update_params = {
      order: {
        status: 'shipped'
      }
    }
    
    put "/api/v1/orders/#{@order.id}", params: update_params, as: :json
    assert_response :forbidden
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
    assert_equal 'Access denied', json_response['error']
  end

  test "should delete order when authenticated and authorized" do
    sign_in @user
    
    delete "/api/v1/orders/#{@order.id}"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('message')
    assert_equal 'Order deleted successfully', json_response['message']
    
    # Verify order is deleted
    assert_raises(Mongoid::Errors::DocumentNotFound) do
      Order.find(@order.id)
    end
  end

  test "should not delete order without authentication" do
    delete "/api/v1/orders/#{@order.id}"
    assert_response :unauthorized
  end

  test "should not delete other user's order" do
    sign_in @other_user
    
    delete "/api/v1/orders/#{@order.id}"
    assert_response :forbidden
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
    assert_equal 'Access denied', json_response['error']
  end

  test "should calculate correct total for order with multiple items" do
    sign_in @user
    
    order_params = {
      order: {
        shipping_address: '789 Another St, Another City, AC 11111',
        billing_address: '789 Another St, Another City, AC 11111',
        line_items: [
          {
            product_id: @product1.id.to_s,
            quantity: 3
          },
          {
            product_id: @product2.id.to_s,
            quantity: 2
          }
        ]
      }
    }
    
    post "/api/v1/orders", params: order_params, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    order_data = json_response['data']
    
    expected_total = (@product1.price * 3) + (@product2.price * 2)
    assert_equal expected_total.to_s, order_data['total']
    
    # Verify order items have correct prices
    line_items = order_data['line_items']
    product1_item = line_items.find { |item| item['product']['name'] == @product1.name }
    product2_item = line_items.find { |item| item['product']['name'] == @product2.name }
    
    assert_equal 3, product1_item['quantity']
    assert_equal @product1.price.to_s, product1_item['price']
    assert_equal 2, product2_item['quantity']
    assert_equal @product2.price.to_s, product2_item['price']
  end

  private

  def sign_in(user)
    post user_session_path, params: {
      user: {
        email: user.email,
        password: 'password123'
      }
    }
  end
end
