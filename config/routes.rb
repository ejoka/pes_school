Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  
  root to: "users#dashboard"
  
  # Admin namespace
  namespace :admin do
    get 'dashboard', to: 'dashboard#index'
    resources :users do
      member do
        get 'assign_resources'
        post 'save_resource_assignment'
      end
    end
    resources :categories
    resources :school_classes
    resources :subjects
  end
  
  # User routes
  get "dashboard", to: "users#dashboard"
  get "profile", to: "users#profile"
  patch "profile", to: "users#update_profile"
end