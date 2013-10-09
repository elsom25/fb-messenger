Starterapp::Application.routes.draw do
  match '/auth/:service/callback' => 'services#create', via: %i(get post)
  match '/auth/failure' => 'services#failure', via: %i(get post)
  match '/logout' => 'sessions#destroy', via: %i(get delete), as: :logout

  get '/login', to: redirect('/auth/facebook'), as: :login

  resources :services, only: %i(create destroy)
  root 'pages#home'

end
