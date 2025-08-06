require 'test_helper'

class Api::V1::CategoriesTest < ActionDispatch::IntegrationTest
  def setup
    @category = Category.create!(
      name: 'Electronics',
      description: 'Electronic devices and gadgets',
      active: true
    )
    
    @inactive_category = Category.create!(
      name: 'Inactive Category',
      description: 'This category is inactive',
      active: false
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
    Category.delete_all
    User.delete_all
  end

  test "should get categories index" do
    get "/api/v1/categories"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('data')
    assert_equal 2, json_response['data'].length
    
    # Verify category data structure
    category_data = json_response['data'].find { |c| c['name'] == @category.name }
    assert_not_nil category_data
    assert_equal @category.name, category_data['name']
    assert_equal @category.description, category_data['description']
    assert_equal @category.active, category_data['active']
  end

  test "should get only active categories when filtered" do
    get "/api/v1/categories?active=true"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response['data'].length
    assert_equal @category.name, json_response['data'][0]['name']
    assert json_response['data'][0]['active']
  end

  test "should show category" do
    get "/api/v1/categories/#{@category.id}"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('data')
    assert_equal @category.name, json_response['data']['name']
    assert_equal @category.description, json_response['data']['description']
    assert_equal @category.active, json_response['data']['active']
  end

  test "should return 404 for non-existent category" do
    get "/api/v1/categories/nonexistent"
    assert_response :not_found
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
    assert_equal 'Category not found', json_response['error']
  end

  test "should create category when authenticated" do
    sign_in @user
    
    category_params = {
      category: {
        name: 'Books & Media',
        description: 'Books, magazines, and digital media',
        active: true
      }
    }
    
    post "/api/v1/categories", params: category_params, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('data')
    assert json_response.has_key?('message')
    assert_equal 'Category created successfully', json_response['message']
    assert_equal 'Books & Media', json_response['data']['name']
  end

  test "should not create category without authentication" do
    category_params = {
      category: {
        name: 'Books & Media',
        description: 'Books, magazines, and digital media',
        active: true
      }
    }
    
    post "/api/v1/categories", params: category_params, as: :json
    assert_response :unauthorized
  end

  test "should not create category with invalid data" do
    sign_in @user
    
    category_params = {
      category: {
        name: '',
        description: '',
        active: true
      }
    }
    
    post "/api/v1/categories", params: category_params, as: :json
    assert_response :unprocessable_entity
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
  end

  test "should not create duplicate category name" do
    sign_in @user
    
    category_params = {
      category: {
        name: @category.name,  # Duplicate name
        description: 'Another electronics category',
        active: true
      }
    }
    
    post "/api/v1/categories", params: category_params, as: :json
    assert_response :unprocessable_entity
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
    assert_includes json_response['error'], 'Name has already been taken'
  end

  test "should update category when authenticated" do
    sign_in @user
    
    update_params = {
      category: {
        name: 'Updated Electronics',
        description: 'Updated description for electronics'
      }
    }
    
    put "/api/v1/categories/#{@category.id}", params: update_params, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('data')
    assert json_response.has_key?('message')
    assert_equal 'Category updated successfully', json_response['message']
    assert_equal 'Updated Electronics', json_response['data']['name']
    assert_equal 'Updated description for electronics', json_response['data']['description']
  end

  test "should not update category without authentication" do
    update_params = {
      category: {
        name: 'Updated Electronics'
      }
    }
    
    put "/api/v1/categories/#{@category.id}", params: update_params, as: :json
    assert_response :unauthorized
  end

  test "should delete category when authenticated and no products depend on it" do
    sign_in @user
    
    delete "/api/v1/categories/#{@category.id}"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('message')
    assert_equal 'Category deleted successfully', json_response['message']
    
    # Verify category is deleted
    assert_raises(Mongoid::Errors::DocumentNotFound) do
      Category.find(@category.id)
    end
  end

  test "should not delete category with associated products" do
    sign_in @user
    
    # Create a product associated with the category
    Product.create!(
      name: 'Test Product',
      description: 'A test product',
      price: 29.99,
      stock_quantity: 100,
      category: @category,
      sku: "TEST-PROD-#{Time.now.to_i}-#{rand(10000)}"
    )
    
    delete "/api/v1/categories/#{@category.id}"
    assert_response :unprocessable_entity
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
    assert_includes json_response['error'], 'Cannot delete category with associated products'
  end

  test "should not delete category without authentication" do
    delete "/api/v1/categories/#{@category.id}"
    assert_response :unauthorized
  end

  test "should get categories with product counts" do
    # Create products in different categories
    Product.create!(
      name: 'Electronics Product',
      description: 'An electronics product',
      price: 99.99,
      stock_quantity: 10,
      category: @category,
      sku: "ELEC-#{Time.now.to_i}-#{rand(10000)}"
    )
    
    books_category = Category.create!(
      name: 'Books',
      description: 'Books and media',
      active: true
    )
    
    Product.create!(
      name: 'Book Product',
      description: 'A book product',
      price: 19.99,
      stock_quantity: 50,
      category: books_category,
      sku: "BOOK-#{Time.now.to_i}-#{rand(10000)}"
    )
    
    get "/api/v1/categories?include_product_count=true"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    electronics_data = json_response['data'].find { |c| c['name'] == @category.name }
    books_data = json_response['data'].find { |c| c['name'] == books_category.name }
    
    assert_not_nil electronics_data
    assert_not_nil books_data
    assert_equal 1, electronics_data['product_count']
    assert_equal 1, books_data['product_count']
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
