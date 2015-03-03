require 'api_constraints'

Rails.application.routes.draw do
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
      get 'query'
      post 'schedule_inspection'
    end
  end
end
