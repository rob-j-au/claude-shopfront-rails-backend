Rails.application.routes.draw do
  resources :categories
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by uptime monitors and load balancers.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Root route
  root "home#index"

  # Devise authentication routes
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  # Resources
  resources :users, except: [:index, :destroy]
  resources :products do
    collection do
      get :autocomplete
    end
  end
  resources :orders, only: [:index, :show, :create, :update]

  # Cart routes
  get '/cart', to: 'cart#show'
  post '/cart/add', to: 'cart#add'
  patch '/cart/update', to: 'cart#update'
  delete '/cart/remove', to: 'cart#remove'
  delete '/cart/clear', to: 'cart#clear'
  
  # API routes
  namespace :api do
    namespace :v1 do
      resources :products
      resources :categories
      resources :users do
        collection do
          get :profile
        end
      end
      resources :orders
      
      # API Token management routes
      post '/tokens', to: 'tokens#create'
      delete '/tokens', to: 'tokens#destroy'
      get '/tokens/verify', to: 'tokens#verify'
      
      # Cart API routes
      get '/cart', to: 'cart#show'
      post '/cart/add', to: 'cart#add'
      patch '/cart/update', to: 'cart#update'
      delete '/cart/remove', to: 'cart#remove'
      delete '/cart/clear', to: 'cart#clear'
    end
  end
end
