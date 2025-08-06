require 'test_helper'

class Api::V1::UsersTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      first_name: 'Test',
      last_name: 'User',
      email: "test#{Time.now.to_i}@example.com",
      password: 'password123',
      password_confirmation: 'password123'
    )
    
    @other_user = User.create!(
      first_name: 'Other',
      last_name: 'User',
      email: "other#{Time.now.to_i}@example.com",
      password: 'password123',
      password_confirmation: 'password123'
    )
  end

  def teardown
    User.delete_all
  end

  test "should get user profile when authenticated" do
    sign_in @user
    
    get "/api/v1/users/profile"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('data')
    assert_equal @user.email, json_response['data']['email']
    assert_equal @user.first_name, json_response['data']['first_name']
    assert_equal @user.last_name, json_response['data']['last_name']
    assert_not json_response['data'].has_key?('encrypted_password')
    assert_not json_response['data'].has_key?('reset_password_token')
  end

  test "should not get user profile without authentication" do
    get "/api/v1/users/profile"
    assert_response :unauthorized
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
    assert_equal 'Authentication required', json_response['error']
  end

  test "should show user" do
    sign_in @user
    
    get "/api/v1/users/#{@other_user.id}"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('data')
    assert_equal @other_user.email, json_response['data']['email']
    assert_equal @other_user.first_name, json_response['data']['first_name']
    assert_equal @other_user.last_name, json_response['data']['last_name']
    assert_not json_response['data'].has_key?('encrypted_password')
    assert_not json_response['data'].has_key?('reset_password_token')
  end

  test "should return 404 for non-existent user" do
    sign_in @user
    
    get "/api/v1/users/nonexistent"
    assert_response :not_found
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
    assert_equal 'User not found', json_response['error']
  end

  test "should create user" do
    user_params = {
      user: {
        first_name: 'New',
        last_name: 'User',
        email: 'new@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      }
    }
    
    post "/api/v1/users", params: user_params, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('data')
    assert json_response.has_key?('message')
    assert_equal 'User created successfully', json_response['message']
    assert_equal 'New', json_response['data']['first_name']
    assert_equal 'User', json_response['data']['last_name']
    assert_equal 'new@example.com', json_response['data']['email']
    assert_not json_response['data'].has_key?('encrypted_password')
  end

  test "should not create user with invalid data" do
    user_params = {
      user: {
        first_name: '',
        last_name: '',
        email: 'invalid-email',
        password: '123',
        password_confirmation: '456'
      }
    }
    
    post "/api/v1/users", params: user_params, as: :json
    assert_response :unprocessable_entity
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
  end

  test "should not create user with duplicate email" do
    user_params = {
      user: {
        first_name: 'Duplicate',
        last_name: 'User',
        email: @user.email,
        password: 'password123',
        password_confirmation: 'password123'
      }
    }
    
    post "/api/v1/users", params: user_params, as: :json
    assert_response :unprocessable_entity
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
    assert_includes json_response['error'], 'Email'
  end

  test "should update user when authenticated" do
    sign_in @user
    
    update_params = {
      user: {
        first_name: 'Updated',
        last_name: 'Name'
      }
    }
    
    put "/api/v1/users/#{@user.id}", params: update_params, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('data')
    assert json_response.has_key?('message')
    assert_equal 'User updated successfully', json_response['message']
    assert_equal 'Updated', json_response['data']['first_name']
    assert_equal 'Name', json_response['data']['last_name']
  end

  test "should not update user without authentication" do
    update_params = {
      user: {
        first_name: 'Updated',
        last_name: 'Name'
      }
    }
    
    put "/api/v1/users/#{@user.id}", params: update_params, as: :json
    assert_response :unauthorized
  end

  test "should update user password when authenticated" do
    sign_in @user
    
    update_params = {
      user: {
        password: 'newpassword123',
        password_confirmation: 'newpassword123'
      }
    }
    
    put "/api/v1/users/#{@user.id}", params: update_params, as: :json
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('message')
    assert_equal 'User updated successfully', json_response['message']
  end

  test "should not update user with invalid password confirmation" do
    sign_in @user
    
    update_params = {
      user: {
        password: 'newpassword123',
        password_confirmation: 'differentpassword'
      }
    }
    
    put "/api/v1/users/#{@user.id}", params: update_params, as: :json
    assert_response :unprocessable_entity
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('error')
  end

  test "should delete user when authenticated" do
    sign_in @user
    
    delete "/api/v1/users/#{@user.id}"
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.has_key?('message')
    assert_equal 'User deleted successfully', json_response['message']
    
    # Verify user is deleted
    assert_raises(Mongoid::Errors::DocumentNotFound) do
      User.find(@user.id)
    end
  end

  test "should not delete user without authentication" do
    delete "/api/v1/users/#{@user.id}"
    assert_response :unauthorized
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
