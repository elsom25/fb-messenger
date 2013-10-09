PlatformDashboard::Application.routes.draw do
  root 'pages#home'

  match '/auth/:service/callback' => 'services#create', via: %i(get post)
  match '/auth/failure' => 'services#failure', via: %i(get post)
  match '/logout' => 'sessions#destroy', via: %i(get delete), as: :logout

  get '/login', to: redirect('/auth/facebook'), as: :login

  resources :services, only: %i(create destroy)
  resources :messages, only: %i(index new create)

  # facebook channel.html
  get '/channel.html' => proc {
    [
      200,
      {
        'Pragma'        => 'public',
        'Cache-Control' => "max-age=#{1.year.to_i}",
        'Expires'       => 1.year.from_now.to_s(:rfc822),
        'Content-Type'  => 'text/html'
      },
      ['<script type="text/javascript" src="//connect.facebook.net/en_US/all.js"></script>']
    ]
  }

end
