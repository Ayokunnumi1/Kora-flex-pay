Rails.application.routes.draw do
  get 'mobile_money_transactions/create'
  # get 'mobile_money/create'
  root 'users#index'
  get '/payment_success', to: 'payments#success', as: 'payment_success'
  resources :users, only: [:index]
  resources :mobile_money_transactions, only: [:new, :create, :index]
  
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
