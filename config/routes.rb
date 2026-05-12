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
    
    # Settings routes
    get 'settings', to: 'settings#index'
    get 'school_settings', to: 'settings#school_settings'
    post 'update_school_settings', to: 'settings#update_school_settings'
    get 'color_settings', to: 'settings#color_settings'
    post 'update_color_settings', to: 'settings#update_color_settings'
    resources :settings, only: [:index, :edit, :update]

    # Examination
    resources :exam_grades
    resources :exam_types
    resources :exam_schedules
    
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
    resources :students do
      resources :student_fees do
        collection do
          get 'bulk_add'
          post 'bulk_add'
          get 'generate_invoice'
          post 'sync_invoices'
        end
      end
      resources :payments
      resources :invoices, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
        collection do
          get 'student_invoices'
        end
        member do
          post 'send_invoice'
          get 'download_pdf'
          post 'refresh'
        end
      end
    end
    
        # Collection routes (non-nested)
    get 'all_invoices', to: 'invoices#index', as: :all_invoices
    get 'all_payments', to: 'all_payments#index', as: :all_payments
    get 'all_students_fees', to: 'student_fees#all_students', as: :all_students_fees
    
    resources :fee_types
    resources :invoices, only: [] 
  end
  
  # User profile routes - use a different name to avoid conflict
  resource :user_profile, only: [:show, :edit, :update], controller: 'users', as: :user_profile
  
  # User dashboard
  get 'dashboard', to: 'users#dashboard'
end