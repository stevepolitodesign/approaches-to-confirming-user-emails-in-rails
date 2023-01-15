Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "users#new"
  resources :confirmations, only: :edit, param: :signed_id
  resources :users, only: [:create, :new, :show]
end
