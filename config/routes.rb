Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'homes#index'
  get 'home', to: 'homes#index'
  resources :gyms, only: [:create]
end
