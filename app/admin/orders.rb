ActiveAdmin.register Order do
  # Permitted parameters for Mongoid
  permit_params :status, :shipping_address, :billing_address

  # Custom scopes instead of Ransack filters
  scope :all, default: true
  scope :pending, -> { where(status: 'pending') }
  scope :processing, -> { where(status: 'processing') }
  scope :shipped, -> { where(status: 'shipped') }
  scope :delivered, -> { where(status: 'delivered') }
  scope :cancelled, -> { where(status: 'cancelled') }

  # Custom filters for Mongoid (no Ransack dependency)
  filter :order_number, as: :string
  filter :status, as: :select, collection: Order::STATUSES
  filter :user, as: :select, collection: -> { User.all.map { |u| [u.email, u.id] } }
  filter :created_at, as: :date_range

  # Index page configuration
  index do
    selectable_column
    id_column
    column :order_number
    column :user do |order|
      link_to order.user.email, admin_user_path(order.user) if order.user
    end
    column :status do |order|
      status_tag order.status, class: order.status
    end
    column :total_amount do |order|
      number_to_currency(order.total_amount)
    end
    column :line_items_count do |order|
      order.line_items.count
    end
    column :created_at
    actions
  end

  # Show page configuration
  show do
    attributes_table do
      row :id
      row :order_number
      row :user do |order|
        link_to order.user.email, admin_user_path(order.user) if order.user
      end
      row :status do |order|
        status_tag order.status, class: order.status
      end
      row :total_amount do |order|
        number_to_currency(order.total_amount)
      end
      row :shipping_address
      row :billing_address
      row :created_at
      row :updated_at
    end

    panel 'Line Items' do
      table_for order.line_items do
        column :product do |line_item|
          link_to line_item.product.name, admin_product_path(line_item.product) if line_item.product
        end
        column :quantity
        column :price do |line_item|
          number_to_currency(line_item.price)
        end
        column :total do |line_item|
          number_to_currency(line_item.quantity * line_item.price)
        end
      end
    end
  end

  # Form configuration
  form do |f|
    f.inputs 'Order Details' do
      f.input :status, as: :select, collection: Order::STATUSES, include_blank: false
      f.input :shipping_address, as: :text
      f.input :billing_address, as: :text
    end
    f.actions
  end

  # Batch actions for order management
  batch_action :mark_as_processing do |ids|
    Order.in(id: ids).update_all(status: 'processing')
    redirect_to collection_path, alert: "Orders marked as processing."
  end

  batch_action :mark_as_shipped do |ids|
    Order.in(id: ids).update_all(status: 'shipped')
    redirect_to collection_path, alert: "Orders marked as shipped."
  end

  batch_action :mark_as_delivered do |ids|
    Order.in(id: ids).update_all(status: 'delivered')
    redirect_to collection_path, alert: "Orders marked as delivered."
  end

  batch_action :cancel_orders do |ids|
    Order.in(id: ids).update_all(status: 'cancelled')
    redirect_to collection_path, alert: "Orders cancelled."
  end
end
