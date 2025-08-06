class Api::V1::BaseController < ApplicationController
  # Skip CSRF protection for API requests
  skip_before_action :verify_authenticity_token
  
  # Skip browser version check for API requests
  skip_before_action :allow_browser, raise: false
  
  # API responses should be JSON
  respond_to :json
  
  # Handle authentication for API requests
  before_action :authenticate_api_user!
  
  private
  
  def authenticate_api_user!
    return true unless action_requires_authentication?
    
    # Try token-based authentication first
    if authenticate_with_token
      return true
    end
    
    # Fall back to session-based authentication
    if user_signed_in?
      return true
    end
    
    render_error('You need to sign in or sign up before continuing.', :unauthorized)
    return false
  end
  
  def authenticate_with_token
    token = extract_token_from_request
    return false if token.blank?
    
    @current_user = User.find_by_api_token(token)
    return @current_user.present?
  end
  
  def extract_token_from_request
    # Check Authorization header first (Bearer token)
    if request.headers['Authorization'].present?
      auth_header = request.headers['Authorization']
      return auth_header.split(' ').last if auth_header.start_with?('Bearer ')
    end
    
    # Check X-API-Token header
    return request.headers['X-API-Token'] if request.headers['X-API-Token'].present?
    
    # Check api_token parameter
    return params[:api_token] if params[:api_token].present?
    
    nil
  end
  
  def current_user
    @current_user || super
  end
  
  def action_requires_authentication?
    # Define which actions require authentication
    # Override this method in specific controllers as needed
    !%w[index show].include?(action_name)
  end
  
  def render_error(message, status = :unprocessable_entity)
    render json: { error: message }, status: status
  end
  
  def render_success(data, message = nil)
    response = { data: data }
    response[:message] = message if message
    render json: response
  end
end
