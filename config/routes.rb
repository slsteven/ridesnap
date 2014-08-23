Rails.application.routes.draw do
  root 'pages#home'

  # Example of regular route:
  get '/how'          => 'pages#home'
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
      get 'query'
      post 'schedule_inspection'
    end
  end
end
