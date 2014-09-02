require 'api_constraints'

Rails.application.routes.draw do
  root 'pages#home'

  # Example of regular route:
  get '/how'          => 'pages#how'
  get '/start'        => 'pages#start'
  get '/about'        => 'pages#about'
  get '/contact'      => 'pages#contact'
  get '/faq'          => 'pages#faq'
  get '/agent'        => 'pages#agent'

  namespace :api, defaults: {format: 'json'} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true) do
      resources :tests
    end
    # scope module: :v2, constraints: ApiConstraints.new(version: 2) do
    #   resources :tests
    # end
  end

  resources :users do
    collection do
      post 'agent'
    end
  end

  resources :vehicles do
    collection do
      get 'make_query'
      get 'model_query'
      get 'year_query'
      get 'style_query'
      get 'query'
      post 'schedule_confirm'
    end
  end

  resources :cities, only: [:create]
end
