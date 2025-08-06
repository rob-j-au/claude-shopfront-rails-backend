class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :description, type: String
  field :price, type: BigDecimal
  field :stock_quantity, type: Integer
  field :sku, type: String
  field :active, type: Boolean, default: true

  belongs_to :category, optional: true
  has_many :line_items, dependent: :destroy

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :sku, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
  scope :in_stock, -> { where(:stock_quantity.gt => 0) }

  def in_stock?
    stock_quantity > 0
  end

  def formatted_price
    "$#{'%.2f' % price}"
  end

  # Generate consistent image URLs using Lorem Picsum
  def image_url(width: 400, height: 300)
    # Use product ID hash for consistent images
    seed = id.to_s.hash.abs % 1000
    "https://picsum.photos/seed/#{seed}/#{width}/#{height}"
  end

  def thumbnail_url(size: 150)
    image_url(width: size, height: size)
  end

  def large_image_url
    image_url(width: 800, height: 600)
  end
end
