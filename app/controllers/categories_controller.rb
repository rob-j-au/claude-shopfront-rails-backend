class CategoriesController < InheritedResources::Base

  def show
    # Load the category (inherited from InheritedResources)
    @category = Category.find(params[:id])
    
    # Load all active products for this category
    @products = @category.products.active.includes(:category)
    
    # Pagination for products if there are many
    page = params[:page]&.to_i || 1
    per_page = 12
    page = 1 if page < 1
    
    @total_count = @products.count
    @total_pages = (@total_count.to_f / per_page).ceil
    offset = (page - 1) * per_page
    
    @products = @products.skip(offset).limit(per_page).to_a
    @current_page = page
    @has_next_page = page < @total_pages
  end

  private

    def category_params
      params.require(:category).permit(:name, :description, :active)
    end

end
