Rails.application.routes.draw do
  root 'pages#home'

  # Example of regular route:
  get '/how'          => 'pages#how'
  get '/start'        => 'pages#start'
  get '/about'        => 'pages#about'
  get '/contact'      => 'pages#contact'
  get '/faq'          => 'pages#faq'
  get '/agent'        => 'pages#agent'
  get '/city'         => 'pages#city'

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
end
