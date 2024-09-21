Rails.application.routes.draw do
  root 'users#index'
  resources :users, only: [:index]
  resources :bank_transfers do
    collection do
      post :create
    end
  end
  resources :payouts do
    collection do
      post :create
    end
  end
end
