Rails.application.routes.draw do
  resources :users
  resources :things
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
  if Rails.env.test?
    match '/:controller/:action'
  end
end
