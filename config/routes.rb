Rails.application.routes.draw do

  devise_for :admins, skip: [:registrations]
  get 'mobile_money_transactions/create'
  # get 'mobile_money/create'
  devise_for :users
  root 'users#index'
  get 'admins/index'

  get '/payment_success', to: 'payments#success', as: 'payment_success'
  resources :users, only: [:index, :show]
  resources :mobile_money_transactions, only: [:new, :create, :index]

  resources :bank_transfers do
    collection do
      post :create
    end
  end

  resources :payouts do
    member do
      get :edit
      patch :update
    end
  end

end
