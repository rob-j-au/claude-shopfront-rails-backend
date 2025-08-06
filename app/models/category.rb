class Category
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name, type: String
  field :description, type: String
  field :active, type: Boolean, default: true
  
  has_many :products, dependent: :restrict_with_error
  
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order_by(name: :asc) }
  
  def to_s
    name
  end
end
