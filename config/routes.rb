Rails.application.routes.draw do
  devise_for :users
  
  root to: "users#dashboard"
  
  # Admin routes
  get "admin/dashboard", to: "admin#dashboard"
  get "admin/users", to: "admin#users"
  get "admin/users/:id/edit", to: "admin#edit_user", as: "edit_admin_user"
  patch "admin/users/:id", to: "admin#update_user", as: "update_admin_user"
  delete "admin/users/:id", to: "admin#delete_user", as: "delete_admin_user"
  get "admin/users/:id/assign_resources", to: "admin#assign_resources", as: "assign_resources_admin_user"
  post "admin/users/:id/save_resource_assignment", to: "admin#save_resource_assignment", as: "save_resource_assignment_admin_user"
  
  # User routes
  get "dashboard", to: "users#dashboard"
  get "profile", to: "users#profile"
  patch "profile", to: "users#update_profile"
  
  # Resource routes
  resources :categories
  resources :school_classes
  resources :subjects

  get "up" => "rails/health#show", as: :rails_health_check
end