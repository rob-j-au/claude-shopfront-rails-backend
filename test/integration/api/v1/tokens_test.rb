require 'test_helper'

class Api::V1::TokensTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      first_name: 'John',
      last_name: 'Doe',
      email: "john.doe.#{Time.current.to_i}@example.com",
      password: 'password123',
      password_confirmation: 'password123'
    )
  end

  def teardown
    User.destroy_all
  end

  # Test token generation
  test "should generate API token when authenticated" do
    # Sign in user first
    post '/users/sign_in', params: {
      user: {
        email: @user.email,
        password: 'password123'
      }
    }
    
    # Generate API token
    post '/api/v1/tokens'
    
    assert_response :success
    json_response = JSON.parse(response.body)
    
    assert json_response['data']['api_token'].present?
    assert json_response['data']['expires_at'].present?
    assert_equal @user.email, json_response['data']['user']['email']
    assert_equal 'API token generated successfully', json_response['message']
    
    # Verify token was saved to user
    @user.reload
    assert @user.api_token.present?
    assert @user.api_token_expires_at.present?
  end

  test "should not generate API token without authentication" do
    post '/api/v1/tokens'
    
    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal 'You need to sign in or sign up before continuing.', json_response['error']
  end

  # Test token verification
  test "should verify valid API token" do
    token = @user.generate_api_token!
    
    get '/api/v1/tokens/verify', headers: { 'Authorization' => "Bearer #{token}" }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    
    assert_equal true, json_response['data']['valid']
    assert json_response['data']['expires_at'].present?
    assert_equal @user.email, json_response['data']['user']['email']
  end

  test "should not verify invalid API token" do
    get '/api/v1/tokens/verify', headers: { 'Authorization' => 'Bearer invalid_token' }
    
    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal 'You need to sign in or sign up before continuing.', json_response['error']
  end

  test "should not verify expired API token" do
    @user.api_token = SecureRandom.hex(32)
    @user.api_token_expires_at = 1.day.ago
    @user.save!
    
    get '/api/v1/tokens/verify', headers: { 'Authorization' => "Bearer #{@user.api_token}" }
    
    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal 'You need to sign in or sign up before continuing.', json_response['error']
  end

  # Test token revocation
  test "should revoke API token when authenticated with token" do
    token = @user.generate_api_token!
    
    delete '/api/v1/tokens', headers: { 'Authorization' => "Bearer #{token}" }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 'API token revoked successfully', json_response['message']
    
    # Verify token was removed from user
    @user.reload
    assert_nil @user.api_token
    assert_nil @user.api_token_expires_at
  end

  # Test different token authentication methods
  test "should authenticate with Bearer token in Authorization header" do
    token = @user.generate_api_token!
    
    get '/api/v1/products', headers: { 'Authorization' => "Bearer #{token}" }
    
    assert_response :success
  end

  test "should authenticate with X-API-Token header" do
    token = @user.generate_api_token!
    
    get '/api/v1/products', headers: { 'X-API-Token' => token }
    
    assert_response :success
  end

  test "should authenticate with api_token parameter" do
    token = @user.generate_api_token!
    
    get "/api/v1/products?api_token=#{token}"
    
    assert_response :success
  end

  # Test token authentication with protected endpoints
  test "should access protected endpoint with valid token" do
    token = @user.generate_api_token!
    
    post '/api/v1/products', 
         params: { 
           product: { 
             name: 'Test Product', 
             price: 19.99, 
             description: 'Test Description',
             sku: "TEST-VALID-#{Time.current.to_f.to_s.gsub('.', '')}",
             category: 'Electronics',
             stock_quantity: 10
           } 
         },
         headers: { 'Authorization' => "Bearer #{token}" }
    
    assert_response :success
  end

  test "should not access protected endpoint with invalid token" do
    post '/api/v1/products', 
         params: { 
           product: { 
             name: 'Test Product', 
             price: 19.99, 
             description: 'Test Description',
             sku: "TEST-INVALID-#{Time.current.to_f.to_s.gsub('.', '')}",
             category: 'Electronics',
             stock_quantity: 10
           } 
         },
         headers: { 'Authorization' => 'Bearer invalid_token' }
    
    assert_response :unauthorized
  end

  # Test fallback to session authentication
  test "should fallback to session authentication when no token provided" do
    # Sign in user with session
    post '/users/sign_in', params: {
      user: {
        email: @user.email,
        password: 'password123'
      }
    }
    
    # Access protected endpoint without token (should use session)
    post '/api/v1/products', 
         params: { 
           product: { 
             name: 'Test Product', 
             price: 19.99, 
             description: 'Test Description',
             sku: "TEST-SESSION-#{Time.current.to_f.to_s.gsub('.', '')}",
             category: 'Electronics',
             stock_quantity: 10
           } 
         }
    
    assert_response :success
  end
end
