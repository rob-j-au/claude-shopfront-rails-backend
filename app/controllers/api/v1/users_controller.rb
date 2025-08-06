class Api::V1::UsersController < Api::V1::BaseController
  before_action :set_user, only: [:show, :update, :destroy]
  
  # GET /api/v1/users/profile
  def profile
    if user_signed_in?
      render_success(current_user.as_json(except: [:encrypted_password, :reset_password_token]))
    else
      render_error('Authentication required', :unauthorized)
    end
  end
  
  # GET /api/v1/users/:id
  def show
    render_success(@user.as_json(except: [:encrypted_password, :reset_password_token]))
  end
  
  # POST /api/v1/users
  def create
    @user = User.new(user_params)
    
    if @user.save
      render_success(@user.as_json(except: [:encrypted_password, :reset_password_token]), 'User created successfully')
    else
      render_error(@user.errors.full_messages.join(', '))
    end
  end
  
  # PATCH/PUT /api/v1/users/:id
  def update
    if @user.update(user_params)
      render_success(@user.as_json(except: [:encrypted_password, :reset_password_token]), 'User updated successfully')
    else
      render_error(@user.errors.full_messages.join(', '))
    end
  end
  
  # DELETE /api/v1/users/:id
  def destroy
    @user.destroy
    render_success(nil, 'User deleted successfully')
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    render_error('User not found', :not_found)
  end
  
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end
  
  def action_requires_authentication?
    # All user operations require authentication except creation
    action_name != 'create'
  end
end
