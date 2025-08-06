ActiveAdmin.register Product do
  # Permitted parameters for Mongoid
  permit_params :name, :description, :price, :sku, :category, :active, :stock_quantity

  # Custom scopes instead of Ransack filters
  scope :all, default: true
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :in_stock, -> { where(:stock_quantity.gt => 0) }
  scope :out_of_stock, -> { where(stock_quantity: 0) }

  # Custom filters for Mongoid (no Ransack dependency)
  filter :name, as: :string
  filter :category, as: :select, collection: -> { Product.distinct(:category) }
  filter :active, as: :boolean
  filter :created_at, as: :date_range

  # Index page configuration
  index do
    selectable_column
    id_column
    column :name
    column :category
    column :price do |product|
      number_to_currency(product.price)
    end
    column :sku
    column :stock_quantity
    column :active
    column :created_at
    actions
  end

  # Show page configuration
  show do
    attributes_table do
      row :id
      row :name
      row :description
      row :category
      row :price do |product|
        number_to_currency(product.price)
      end
      row :sku
      row :stock_quantity
      row :active
      row :created_at
      row :updated_at
    end
  end

  # Form configuration
  form do |f|
    f.inputs 'Product Details' do
      f.input :name
      f.input :description, as: :text
      f.input :category, as: :select, collection: Product.distinct(:category), include_blank: 'Select Category'
      f.input :price, as: :number, step: 0.01
      f.input :sku
      f.input :stock_quantity, as: :number
      f.input :active
    end
    f.actions
  end

  # Batch actions
  batch_action :activate do |ids|
    Product.in(id: ids).update_all(active: true)
    redirect_to collection_path, alert: "Products activated."
  end

  batch_action :deactivate do |ids|
    Product.in(id: ids).update_all(active: false)
    redirect_to collection_path, alert: "Products deactivated."
  end
end
