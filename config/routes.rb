Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Customer uses independent Devise routing
  devise_for :customers, path: "", path_names: {
    sign_in: "login",
    sign_out: "logout",
    sign_up: "register"
  }

  # ============================================
  # Customer Orders (Feature 3.2.1)
  # ============================================
  namespace :customers do
    resources :addresses, only: [ :index, :new, :create, :edit, :update, :destroy ]
    resources :orders, only: [ :index, :show ]
  end

  resources :products, only: [ :index, :show ]
  resources :categories, only: [ :index, :show ]

  resource :cart, only: [ :show ] do
    post "add/:product_id", to: "carts#add", as: :add_to
    patch "update/:product_id", to: "carts#update", as: :update_item
    delete "remove/:product_id", to: "carts#remove", as: :remove_from
    delete "clear", to: "carts#clear", as: :clear
  end

  # ============================================
  # Checkout & Orders
  # ============================================
  resource :checkouts, only: [ :show, :create ] do
    get "address", to: "checkouts#address"
    post "address", to: "checkouts#save_address"
    get "review", to: "checkouts#review"
    get "confirmation", to: "checkouts#confirmation"
  end

  # ============================================
  # Payments (Feature 3.3.1)
  # ============================================
  resources :payments, only: [ :new, :create ] do
    collection do
      get "success", to: "payments#success"
      get "cancel", to: "payments#cancel"
    end
  end

  # ============================================
  # Payments Webhook
  # ============================================
  post "/webhooks/stripe", to: "webhooks#stripe"

  # ============================================
  # Health Check
  # ============================================
  get "/health", to: proc { [ 200, {}, [ "OK" ] ] }
  get "/pages/:slug", to: "pages#show", as: :page

  root "home#index"
end
