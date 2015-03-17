require 'api_constraints'

Rails.application.routes.draw do

  concern :paginatable do
    get '(page/:page)', action: :index, on: :collection, as: ''
  end

  root 'pages#home'
<<<<<<< HEAD

  resources :sessions, only: [:create, :destroy]

  delete '/signout'   => 'sessions#destroy'
  get '/how'          => 'pages#how'
  get '/start'        => 'pages#start'
  get '/about'        => 'pages#about'
  get '/contact'      => 'pages#contact'
  get '/faq'          => 'pages#faq'
  get '/agent'        => 'pages#agent'
  get '/sell'         => 'vehicles#sell'
  get '/buy'        => 'vehicles#buy'
=======
  get '/how'                      => 'pages#how'
  get '/start'                    => 'pages#start'
  get '/about'                    => 'pages#about'
  get '/contact'                  => 'pages#contact'
  get '/faq'                      => 'pages#faq'
  get '/agent'                    => 'pages#agent'
  get '/sell'                     => 'vehicles#sell'
>>>>>>> origin

  namespace :api, defaults: {format: 'json'} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true) do
      resources :vehicles
    end
  end

  resources :sessions, only: [:create, :destroy]
  delete '/signout'               => 'sessions#destroy'
  get '/auth/:provider/callback'  => "sessions##{:provider}"

  resources :users, concerns: :paginatable do
    collection do
      post 'agent'
    end
  end
  resources :rides, concerns: :paginatable # users/vehicles join table
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
    member do
      post 'notify'
    end
    resources :images
  end
  resources :problems # vehicles/trouble_codes join table
  resources :trouble_codes

  resources :cities, only: [:create, :index, :update]
  resources :password_resets, only: [:create, :edit, :update]
end
