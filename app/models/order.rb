class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  # Status constants for ActiveAdmin and other uses
  STATUSES = %w[pending processing shipped delivered cancelled].freeze

  field :status, type: String, default: 'pending'
  field :total_amount, type: BigDecimal
  field :total, type: BigDecimal
  field :order_number, type: String
  field :shipping_address, type: String
  field :billing_address, type: String

  belongs_to :user
  has_many :line_items, dependent: :destroy
  accepts_nested_attributes_for :line_items, allow_destroy: true

  validates :status, inclusion: { in: STATUSES }
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :order_number, uniqueness: true, allow_blank: true
  validate :has_line_items, on: :create

  before_validation :generate_order_number, on: :create
  before_validation :calculate_total

  scope :by_status, ->(status) { where(status: status) }
  scope :recent, -> { order_by(created_at: :desc) }

  def formatted_total_amount
    "$#{'%.2f' % total_amount}"
  end

  def can_be_cancelled?
    cancellable_statuses = %w[pending processing]
    result = cancellable_statuses.include?(status)
    Rails.logger.info "Order #{order_number} can_be_cancelled check: status=#{status}, cancellable=#{result}"
    result
  end

  def calculate_total!
    Rails.logger.info "Calculating total for order #{id || 'new'}"
    calculated_total = line_items.sum(&:total_price)
    Rails.logger.info "Line items total: #{calculated_total} (from #{line_items.count} items)"
    self.total_amount = calculated_total
    self.total = calculated_total
    Rails.logger.info "Updated order totals to: #{calculated_total}"
    save!(validate: false)
  end

  def recalculate_and_save_total!
    calculate_total
    save!(validate: false)
  end

  private

  def generate_order_number
    return if order_number.present?
    self.order_number = "ORD-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end

  def calculate_total
    Rails.logger.info "Calculate total callback triggered for order #{id || 'new'}"
    calculated_total = line_items.sum(&:total_price)
    Rails.logger.info "Calculated total: #{calculated_total} from #{line_items.count} line items"
    self.total_amount = calculated_total || 0
    self.total = calculated_total || 0
    Rails.logger.info "Set total_amount and total to: #{self.total_amount}"
  end

  def has_line_items
    errors.add(:line_items, "must have at least one item") if line_items.empty?
  end
end
