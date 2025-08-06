ActiveAdmin.register User do
  # Permitted parameters for Mongoid
  permit_params :email, :password, :password_confirmation, :admin, :first_name, :last_name

  # Custom scopes instead of Ransack filters
  scope :all, default: true
  scope :admins, -> { where(admin: true) }
  scope :regular_users, -> { where(admin: false) }
  scope :with_orders, -> { where(:id.in => Order.distinct(:user_id)) }

  # Custom filters for Mongoid (no Ransack dependency)
  filter :email, as: :string
  filter :admin, as: :boolean
  filter :created_at, as: :date_range

  # Index page configuration
  index do
    selectable_column
    id_column
    column :email
    column :first_name
    column :last_name
    column :admin
    column :api_token_expires_at do |user|
      user.api_token_expires_at&.strftime('%Y-%m-%d %H:%M')
    end
    column :orders_count do |user|
      user.orders.count
    end
    column :created_at
    actions
  end

  # Show page configuration
  show do
    attributes_table do
      row :id
      row :email
      row :first_name
      row :last_name
      row :admin
      row :api_token do |user|
        user.api_token.present? ? '***' + user.api_token.last(4) : 'None'
      end
      row :api_token_expires_at
      row :orders_count do |user|
        user.orders.count
      end
      row :created_at
      row :updated_at
    end

    panel 'Recent Orders' do
      table_for user.orders.desc(:created_at).limit(10) do
        column :order_number
        column :status
        column :total_amount do |order|
          number_to_currency(order.total_amount)
        end
        column :created_at
        column 'Actions' do |order|
          link_to 'View', admin_order_path(order)
        end
      end
    end
  end

  # Form configuration
  form do |f|
    f.inputs 'User Details' do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :admin
      if f.object.new_record?
        f.input :password
        f.input :password_confirmation
      end
    end
    f.actions
  end

  # Custom member actions
  member_action :revoke_token, method: :post do
    resource.update(api_token: nil, api_token_expires_at: nil)
    redirect_to admin_user_path(resource), notice: 'API token revoked successfully.'
  end

  action_item :revoke_token, only: :show, if: proc { resource.api_token.present? } do
    link_to 'Revoke API Token', revoke_token_admin_user_path(resource), method: :post,
            confirm: 'Are you sure you want to revoke this user\'s API token?'
  end

  # Batch actions
  batch_action :make_admin do |ids|
    User.in(id: ids).update_all(admin: true)
    redirect_to collection_path, alert: "Users promoted to admin."
  end

  batch_action :remove_admin do |ids|
    User.in(id: ids).update_all(admin: false)
    redirect_to collection_path, alert: "Admin privileges removed."
  end
end
