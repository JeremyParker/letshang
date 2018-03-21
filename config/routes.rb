# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :teams
  resources :responses
  resources :options
  resources :users
  resources :plans

  # endpoints for Slack to call
  post 'slack_submission', to: 'slack_submissions#create'
  post 'slack_slash_command', to: 'slack_slash_commands#create'
  get 'auth_redirects', to: 'auth_redirects#index'
end
