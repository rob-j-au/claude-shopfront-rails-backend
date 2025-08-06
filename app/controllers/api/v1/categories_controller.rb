class Api::V1::CategoriesController < Api::V1::BaseController
  before_action :set_category, only: [:show, :update, :destroy]
  
  # GET /api/v1/categories
  def index
    # Apply filters if provided
    categories_query = Category.all
    categories_query = categories_query.where(active: true) if params[:active] == 'true'
    
    # Order by name for consistency
    @categories = categories_query.asc(:name)
    
    # Prepare response data
    categories_data = @categories.map do |category|
      category_json = category.as_json
      
      # Include product count if requested
      if params[:include_product_count] == 'true'
        category_json[:product_count] = category.products.count
      end
      
      category_json
    end
    
    render_success(categories_data)
  end
  
  # GET /api/v1/categories/:id
  def show
    render_success(@category.as_json)
  end
  
  # POST /api/v1/categories
  def create
    @category = Category.new(category_params)
    
    if @category.save
      render_success(@category.as_json, 'Category created successfully')
    else
      render_error(@category.errors.full_messages.join(', '))
    end
  end
  
  # PATCH/PUT /api/v1/categories/:id
  def update
    if @category.update(category_params)
      render_success(@category.as_json, 'Category updated successfully')
    else
      render_error(@category.errors.full_messages.join(', '))
    end
  end
  
  # DELETE /api/v1/categories/:id
  def destroy
    # Check if category has associated products
    if @category.products.exists?
      render_error('Cannot delete category with associated products', :unprocessable_entity)
      return
    end
    
    @category.destroy
    render_success(nil, 'Category deleted successfully')
  end
  
  private
  
  def set_category
    @category = Category.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    render_error('Category not found', :not_found)
  end
  
  def category_params
    params.require(:category).permit(:name, :description, :active)
  end
  
  def action_requires_authentication?
    # Only allow read operations without authentication
    !%w[index show].include?(action_name)
  end
end
