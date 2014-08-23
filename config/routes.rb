Rails.application.routes.draw do
  root 'pages#home'

  get '/how'          => 'pages#how'
  get '/start'        => 'pages#start'
  get '/about'        => 'pages#about'
  get '/contact'      => 'pages#contact'
  get '/faq'          => 'pages#faq'
  get '/agent'        => 'users#agent'
  get '/city'         => 'pages#city'

  resources :vehicles do
    collection do
      get 'query'
      post 'schedule_inspection'
    end
  end
  resources :users
end
