require 'test_helper'

class Api::V1::ProductsTest < ActionDispatch::IntegrationTest
  def setup
    @category = Category.create!(
      name: 'Electronics',
      description: 'Electronic devices and gadgets',
      active: true
    )
    
    @product = Product.create!(
      name: 'Test Product',
      description: 'A test product',
      price: 29.99,
      stock_quantity: 100,
      category: @category,
      sku: "TEST-PROD-#{Time.now.to_i}-#{rand(10000)}-001"
    )
    
    @user = User.create!(
      first_name: 'Test',
      last_name: 'User',
      email: "test#{Time.now.to_i}#{rand(1000)}@example.com",
      password: 'password123',
      password_confirmation: 'password123'
    )
  end

  def teardown
    Product.delete_all
    Category.delete_all
    User.delete_all
  end

  test "should get index" do
    get "/api/v1/products"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('data')
    assert json_response['data'].has_key?('products')
    # Only check that our test product is present, not the exact count
    # since other tests may have created products
    test_product = json_response['data']['products'].find { |p| p['name'] == @product.name }
    assert_not_nil test_product, "Test product '#{@product.name}' not found in response"
    assert_equal @product.name, test_product['name']
    assert_equal @product.price.to_s, test_product['price']
    assert test_product.has_key?('formatted_price')
    # Verify category information is included
    assert_not_nil test_product['category'], "Category should be present in product response"
    assert_equal @product.category.name, test_product['category']
  end

  test "should show product" do
    get "/api/v1/products/#{@product.id}"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('data')
    assert_equal @product.name, json_response['data']['name']
    assert_equal @product.price.to_s, json_response['data']['price']
    assert json_response['data'].has_key?('formatted_price')
    # Verify category information is included
    assert_not_nil json_response['data']['category'], "Category should be present in response"
    assert_equal @product.category.name, json_response['data']['category']
  end

  test "should return 404 for non-existent product" do
    get "/api/v1/products/nonexistent"
    assert_response :not_found
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
    assert_equal 'Product not found', json_response['error']
  end

  test "should create product when authenticated" do
    sign_in @user
    
    books_category = Category.create!(
      name: 'Books',
      description: 'Books and media',
      active: true
    )
    
    product_params = {
      product: {
        name: 'New Product',
        description: 'A new product',
        price: 39.99,
        stock_quantity: 50,
        category_id: books_category.id,
        sku: "NEW-PROD-#{Time.now.to_i}-#{rand(10000)}"
      }
    }
    
    post "/api/v1/products", params: product_params, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('data')
    assert json_response.has_key?('message')
    assert_equal 'Product created successfully', json_response['message']
    assert_equal 'New Product', json_response['data']['name']
    assert_equal '39.99', json_response['data']['price']
  end

  test "should not create product without authentication" do
    books_category = Category.create!(
      name: 'Books',
      description: 'Books and media',
      active: true
    )
    
    product_params = {
      product: {
        name: 'New Product',
        description: 'A new product',
        price: 39.99,
        stock_quantity: 50,
        category_id: books_category.id,
        sku: "NEW-PROD-#{Time.now.to_i}-#{rand(10000)}"
      }
    }
    
    post "/api/v1/products", params: product_params, as: :json
    assert_response :unauthorized
  end

  test "should not create product with invalid data" do
    sign_in @user
    
    books_category = Category.create!(
      name: 'Books',
      description: 'Books and media',
      active: true
    )
    
    product_params = {
      product: {
        name: '',
        description: 'A new product',
        price: -10,
        stock_quantity: -5,
        category_id: books_category.id
      }
    }
    
    post "/api/v1/products", params: product_params, as: :json
    assert_response :unprocessable_entity
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
  end

  test "should update product when authenticated" do
    sign_in @user
    
    update_params = {
      product: {
        name: 'Updated Product',
        price: 49.99
      }
    }
    
    put "/api/v1/products/#{@product.id}", params: update_params, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('data')
    assert json_response.has_key?('message')
    assert_equal 'Product updated successfully', json_response['message']
    assert_equal 'Updated Product', json_response['data']['name']
    assert_equal '49.99', json_response['data']['price']
  end

  test "should not update product without authentication" do
    update_params = {
      product: {
        name: 'Updated Product',
        price: 49.99
      }
    }
    
    put "/api/v1/products/#{@product.id}", params: update_params, as: :json
    assert_response :unauthorized
  end

  test "should delete product when authenticated" do
    sign_in @user
    
    delete "/api/v1/products/#{@product.id}"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('message')
    assert_equal 'Product deleted successfully', json_response['message']
    
    # Verify product is deleted
    assert_raises(Mongoid::Errors::DocumentNotFound) do
      Product.find(@product.id)
    end
  end

  test "should not delete product without authentication" do
    delete "/api/v1/products/#{@product.id}"
    assert_response :unauthorized
  end

  test "should filter products by category" do
    # Create additional category and product
    books_category = Category.create!(
      name: 'Books',
      description: 'Books and media',
      active: true
    )
    
    book_product = Product.create!(
      name: 'Test Book',
      description: 'A test book',
      price: 19.99,
      stock_quantity: 50,
      category: books_category,
      sku: "BOOK-#{Time.now.to_i}-#{rand(10000)}"
    )
    
    # Test filtering by Electronics category
    get "/api/v1/products?category=#{@category.name}"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    electronics_products = json_response['data']['products'].select { |p| p['category'] == @category.name }
    assert electronics_products.any? { |p| p['name'] == @product.name }, "Original test product not found in Electronics category"
    
    # Test filtering by Books category
    get "/api/v1/products?category=#{books_category.name}"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    books_products = json_response['data']['products'].select { |p| p['category'] == books_category.name }
    assert books_products.any? { |p| p['name'] == book_product.name }, "Book product not found in Books category"
  end

  test "should handle products without category" do
    # Create product without category
    product_without_category = Product.create!(
      name: 'Product Without Category',
      description: 'A product without category',
      price: 39.99,
      stock_quantity: 30,
      sku: "PWC-#{Time.now.to_i}-#{rand(10000)}"
    )
    
    get "/api/v1/products/#{product_without_category.id}"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response['data'].has_key?('category')
    assert_nil json_response['data']['category']
  end

  test "should create product without category" do
    sign_in @user
    
    product_params = {
      product: {
        name: 'Product Without Category',
        description: 'A product without category',
        price: 29.99,
        stock_quantity: 25,
        sku: "PWC-#{Time.now.to_i}-#{rand(10000)}"
      }
    }
    
    post "/api/v1/products", params: product_params, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal 'Product created successfully', json_response['message']
    assert_nil json_response['data']['category']
  end

  test "should update product category" do
    sign_in @user
    
    new_category = Category.create!(
      name: 'Home & Garden',
      description: 'Home improvement and garden supplies',
      active: true
    )
    
    update_params = {
      product: {
        category_id: new_category.id
      }
    }
    
    put "/api/v1/products/#{@product.id}", params: update_params, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal 'Product updated successfully', json_response['message']
    assert_equal new_category.name, json_response['data']['category']
    
    # Verify in database
    @product.reload
    assert_equal new_category.id, @product.category_id
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
