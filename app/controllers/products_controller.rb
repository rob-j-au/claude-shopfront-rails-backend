class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    # Pagination parameters
    page = params[:page]&.to_i || 1
    per_page = 3
    
    # Validate page parameter
    page = 1 if page < 1
    
    # Apply filters if provided
    products_query = Product.active.includes(:category)
    if params[:category].present?
      category = Category.where(name: params[:category]).first
      products_query = products_query.where(category: category) if category
    end
    products_query = products_query.where(:name => /#{Regexp.escape(params[:search])}/i) if params[:search].present?
    
    # Calculate pagination
    @total_count = products_query.count
    @total_pages = (@total_count.to_f / per_page).ceil
    offset = (page - 1) * per_page
    
    # Get paginated products (force execution with to_a to avoid lazy loading issues)
    @products = products_query.skip(offset).limit(per_page).to_a
    
    # Debug: Log the actual count vs expected count
    Rails.logger.info "DEBUG: Expected #{per_page} products, got #{@products.length} products"
    Rails.logger.info "DEBUG: Total count: #{@total_count}, Current page: #{page}, Offset: #{offset}"
    
    # Pagination metadata for view
    @current_page = page
    @per_page = per_page
    @has_next_page = page < @total_pages
    @has_prev_page = page > 1
    
    respond_to do |format|
      format.html
      format.json do
        render json: {
          products: @products.map do |product|
            {
              id: product.id.to_s,
              name: product.name,
              description: product.description,
              price: product.price.to_s,
              formatted_price: product.formatted_price,
              sku: product.sku,
              in_stock: product.in_stock?,
              stock_quantity: product.stock_quantity,
              category: product.category ? {
                id: product.category.id.to_s,
                name: product.category.name
              } : nil,
              edit_path: edit_product_path(product),
              show_path: product_path(product),
              delete_path: product_path(product),
              html: render_to_string(partial: 'product_card', locals: { product: product }, formats: [:html])
            }
          end,
          pagination: {
            current_page: @current_page,
            total_pages: @total_pages,
            has_next_page: @has_next_page,
            total_count: @total_count
          }
        }
      end
    end
  end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    
    if @product.save
      redirect_to @product, notice: 'Product was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to @product, notice: 'Product was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_url, notice: 'Product was successfully deleted.'
  end

  def autocomplete
    query = params[:q].to_s.strip
    
    if query.length >= 2
      # Search for products by name (case-insensitive)
      products = Product.active
                       .where(:name => /#{Regexp.escape(query)}/i)
                       .limit(10)
                       .pluck(:name)
                       .uniq
    else
      products = []
    end
    
    render json: products
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock_quantity, :sku, :category_id, :active)
  end
end
