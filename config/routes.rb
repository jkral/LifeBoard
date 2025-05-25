Rails.application.routes.draw do
  resource :session, only: [:new, :create, :destroy]
  resources :passwords, param: :token, only: [:new, :create, :edit, :update]
  resources :users, only: [:new, :create]
  
  # Dashboard
  get 'dashboard', to: 'dashboard#index'
  root to: 'dashboard#index'
  
  # Categories
  resources :categories, only: [:show] do
    resources :subcategories, only: [:show, :update]
  end
  
  # Authentication
  get 'signup', to: 'users#new', as: :signup
  get 'login', to: 'sessions#new', as: :login
  delete 'logout', to: 'sessions#destroy', as: :logout
  
  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end
