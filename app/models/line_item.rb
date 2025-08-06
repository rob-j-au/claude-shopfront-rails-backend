class LineItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :quantity, type: Integer
  field :price, type: BigDecimal

  belongs_to :product
  belongs_to :order

  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :product, presence: true

  before_validation :set_price

  def total_price
    (quantity || 0) * (price || 0)
  end

  def formatted_total_price
    "$#{'%.2f' % total_price}"
  end

  private

  def set_price
    if product && product.price
      self.price = product.price.to_f
    elsif product
      errors.add(:price, "cannot be determined - product price missing")
    else
      errors.add(:product, "must be present to determine price")
    end
  end
end
