Rails.application.routes.draw do
  devise_for :users,
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords'
  },
  path: '',
  path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    sign_up: 'register',
    password: 'password'
  }
  
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
    resources :exam_attendances do
      collection do
        get 'batch_attendance'
        post 'batch_attendance'
        get 'by_exam'
      end
    end
    resources :enter_marks do
      collection do
        get 'batch_marks'
        post 'batch_marks'
        get 'by_exam'
      end
    end

    # Transport routes
    resources :routes
    resources :school_buses
    resources :driver_assignments
    resources :bus_route_assignments
    resources :student_transport_assignments

      # Inventory routes
    resources :inventory_categories
    resources :suppliers
    resources :inventory_items do
      collection do
        get 'low_stock'
      end
    end
    resources :stock_movements, only: [:index, :new, :create, :destroy] do
      collection do
        get 'by_item/:item_id', to: 'stock_movements#by_item', as: :by_item
      end
    end
    resources :stock_receipts do
      member do
        post 'receive'
        post 'cancel'
      end
    end

    # Attendance routes
    get 'attendance', to: 'attendances#select_class', as: :attendance_select
    get 'attendances', to: 'attendances#index', as: :attendances
    get 'attendances/mark', to: 'attendances#mark_attendance', as: :mark_attendance
    post 'attendances/save', to: 'attendances#save_attendance', as: :save_attendance
    get 'attendances/weekly_report', to: 'attendances#weekly_report', as: :attendance_weekly_report
    get 'attendances/student_report', to: 'attendances#student_report', as: :attendance_student_report
    
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

    # Staff routes
    resources :departments
    resources :staff_assignments
    resources :payrolls do
      member do
        patch 'mark_paid'
      end
    end

    # Staff attendance routes
    resources :staff_attendances, only: [:index] do
      collection do
        get 'mark_attendance'
        post 'save_attendance'
        get 'weekly_report'
        get 'monthly_summary'
      end
    end
    resources :staff_leave_requests do
      member do
        patch 'approve'
        patch 'reject'
      end
    end
    
    resources :fee_types
    resources :invoices, only: [] 
  end
  
  # User profile routes - use a different name to avoid conflict
  resource :user_profile, only: [:show, :edit, :update], controller: 'users', as: :user_profile
  
  # User dashboard
  get 'dashboard', to: 'users#dashboard'
end