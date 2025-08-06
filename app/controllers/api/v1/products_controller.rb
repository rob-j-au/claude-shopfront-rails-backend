class Api::V1::ProductsController < Api::V1::BaseController
  before_action :set_product, only: [:show, :update, :destroy]
  
  # GET /api/v1/products
  def index
    # Pagination parameters
    page = params[:page]&.to_i || 1
    per_page = params[:per_page]&.to_i || 10
    
    # Validate pagination parameters
    page = 1 if page < 1
    per_page = 10 if per_page < 1 || per_page > 100
    
    # Apply filters if provided
    products_query = Product.includes(:category)
    
    # Filter by category name if provided
    if params[:category].present?
      category = Category.where(name: params[:category]).first
      products_query = products_query.where(category: category) if category
    end
    
    products_query = products_query.where(:name => /#{Regexp.escape(params[:search])}/i) if params[:search].present?
    
    # Calculate pagination
    total_count = products_query.count
    total_pages = (total_count.to_f / per_page).ceil
    offset = (page - 1) * per_page
    
    # Get paginated products
    @products = products_query.skip(offset).limit(per_page)
    
    # Prepare products data with category information
    products_data = @products.map do |product|
      product_json = product.as_json
      product_json['category'] = product.category&.name
      product_json['formatted_price'] = product.formatted_price
      product_json
    end
    
    # For index, we return products directly as data with pagination metadata
    response_data = {
      products: products_data,
      pagination: {
        current_page: page,
        per_page: per_page,
        total_pages: total_pages,
        total_count: total_count,
        has_next_page: page < total_pages,
        has_prev_page: page > 1
      }
    }
    
    render_success(response_data)
  end
  
  # GET /api/v1/products/:id
  def show
    product_data = @product.as_json
    product_data['category'] = @product.category&.name
    product_data['formatted_price'] = @product.formatted_price
    render_success(product_data)
  end
  
  # POST /api/v1/products
  def create
    @product = Product.new(product_params)
    
    if @product.save
      product_data = @product.as_json
      product_data['category'] = @product.category&.name
      product_data['formatted_price'] = @product.formatted_price
      render_success(product_data, 'Product created successfully')
    else
      render_error(@product.errors.full_messages.join(', '))
    end
  end
  
  # PATCH/PUT /api/v1/products/:id
  def update
    if @product.update(product_params)
      product_data = @product.as_json
      product_data['category'] = @product.category&.name
      product_data['formatted_price'] = @product.formatted_price
      render_success(product_data, 'Product updated successfully')
    else
      render_error(@product.errors.full_messages.join(', '))
    end
  end
  
  # DELETE /api/v1/products/:id
  def destroy
    @product.destroy
    render_success(nil, 'Product deleted successfully')
  end
  
  private
  
  def set_product
    @product = Product.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    render_error('Product not found', :not_found)
  end
  
  def product_params
    params.require(:product).permit(:name, :description, :price, :stock_quantity, :category_id, :sku)
  end
  
  def action_requires_authentication?
    # Only allow read operations without authentication
    !%w[index show].include?(action_name)
  end
end
