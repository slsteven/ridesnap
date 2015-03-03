require 'api_constraints'

Rails.application.routes.draw do

  concern :paginatable do
    get '(page/:page)', action: :index, on: :collection, as: ''
  end

  root 'pages#home'

  resources :sessions, only: [:create, :destroy]

  delete '/signout'               => 'sessions#destroy'
  get '/how'                      => 'pages#how'
  get '/start'                    => 'pages#start'
  get '/about'                    => 'pages#about'
  get '/contact'                  => 'pages#contact'
  get '/faq'                      => 'pages#faq'
  get '/agent'                    => 'pages#agent'
  get '/sell'                     => 'vehicles#sell'
  get '/auth/:provider/callback'  => "sessions##{:provider}"

  namespace :api, defaults: {format: 'json'} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true) do
      resources :vehicles
    end
    # scope module: :v2, constraints: ApiConstraints.new(version: 2) do
    #   resources :vehicles
    # end
  end

  resources :users, concerns: :paginatable do
    collection do
      post 'agent'
    end
  end

  resources :vehicles, concerns: :paginatable do
    collection do
      get 'make_query'
      get 'model_query'
      get 'year_query'
      get 'style_query'
      get 'query'
      get 'search'
      post 'schedule_confirm'
    end
    resources :images
  end

  resources :rides, concerns: :paginatable

  resources :cities, only: [:create, :index, :update]
  resources :password_resets, only: [:create, :edit, :update]
end
