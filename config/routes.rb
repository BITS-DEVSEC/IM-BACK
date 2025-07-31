Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Auth routes
  post "/auth/register", to: "authentication#register"
  post "/auth/customer_register", to: "authentication#customer_register"
  post "/auth/verify_otp", to: "authentication#verify_otp"
  get "auth/verify_email", to: "authentication#verify_email", as: :verify_email
  post "/auth/resend_verification_email", to: "authentication#resend_verification_email"
  post "/auth/login", to: "authentication#login"
  post "/auth/refresh", to: "authentication#refresh_token"
  post "/auth/logout", to: "authentication#logout"
  post "/auth/logout_all", to: "authentication#logout_all"
  post "/auth/forgot_password", to: "authentication#forgot_password"
  post "/auth/reset_password", to: "authentication#reset_password"
  post "auth/change_password", to: "authentication#change_password"

  resources :insurance_types
  resources :vehicles
  resources :quotation_requests do
    post :convert_to_policy, on: :member
  end
  resources :users
  resources :policies

  resources :insurers
  resources :insurance_products
end
