# Rails.application.routes.draw do
#   devise_for :users, controllers: {
#     sessions: 'users/sessions',
#     registrations: 'users/registrations'
#   }
  
#   root to: "users#dashboard"
  
#   # Admin namespace
#   namespace :admin do
#     get 'dashboard', to: 'dashboard#index'
#     resource :profile, only: [:show, :edit, :update], controller: 'profiles'

#     resources :users do
#       member do
#         get 'assign_resources'
#         post 'save_resource_assignment'
#       end
#     end
#     resources :categories
#     resources :school_classes
#     resources :subjects
#   end

#    # User routes
#   get "dashboard", to: "users#dashboard"
#   resource :profile, only: [:show, :update], controller: 'users/profile'
#   patch "profile", to: "users#update_profile"
# end

# Rails.application.routes.draw do
#   devise_for :users
  
#   root to: "users#dashboard"
  
#   # Admin namespace
#   namespace :admin do
#     get 'dashboard', to: 'dashboard#index'
#     get 'profile', to: 'profiles#show'
#     get 'profile/edit', to: 'profiles#edit'
#     patch 'profile', to: 'profiles#update'
#     put 'profile', to: 'profiles#update'
    
#     resources :users do
#       member do
#         get 'assign_resources'
#         post 'save_resource_assignment'
#       end
#     end
#     resources :categories
#     resources :school_classes
#     resources :subjects
#   end
  
#   # User routes - use resource to generate proper helpers
#   resource :profile, only: [:show, :edit, :update], controller: 'users'
  
#   # User dashboard
#   get 'dashboard', to: 'users#dashboard'
# end

Rails.application.routes.draw do
  devise_for :users
  
  root to: "users#dashboard"
  
  # Admin namespace
  namespace :admin do
    get 'dashboard', to: 'dashboard#index'
    
    # Admin profile routes
    resource :profile, only: [:show, :edit, :update], controller: 'profiles', as: :admin_profile
    
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
  
  # User profile routes - use a different name to avoid conflict
  resource :user_profile, only: [:show, :edit, :update], controller: 'users', as: :user_profile
  
  # User dashboard
  get 'dashboard', to: 'users#dashboard'
end