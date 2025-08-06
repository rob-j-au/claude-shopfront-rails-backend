class Api::V1::TokensController < Api::V1::BaseController
  # Skip token authentication for token generation endpoint
  skip_before_action :authenticate_api_user!, only: [:create]
  before_action :authenticate_user_for_token_creation!, only: [:create]
  
  # POST /api/v1/tokens
  def create
    token = current_user.generate_api_token!
    render_success({
      api_token: token,
      expires_at: current_user.api_token_expires_at,
      user: {
        id: current_user.id.to_s,
        email: current_user.email,
        full_name: current_user.full_name
      }
    }, 'API token generated successfully')
  end
  
  # DELETE /api/v1/tokens
  def destroy
    current_user.revoke_api_token!
    render_success({}, 'API token revoked successfully')
  end
  
  # GET /api/v1/tokens/verify
  def verify
    render_success({
      valid: true,
      expires_at: current_user.api_token_expires_at,
      user: {
        id: current_user.id.to_s,
        email: current_user.email,
        full_name: current_user.full_name
      }
    }, 'Token is valid')
  end
  
  private
  
  def authenticate_user_for_token_creation!
    unless user_signed_in?
      render_error('You need to sign in or sign up before continuing.', :unauthorized)
      return false
    end
  end
end
