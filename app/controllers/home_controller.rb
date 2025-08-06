class HomeController < ApplicationController
  def index
    @featured_products = Product.active.in_stock.limit(6)
  end
end
