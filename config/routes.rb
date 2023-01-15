Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "users#new"
  resources :confirmations, only: :edit
  resources :users, only: [:create, :new, :show]
end
