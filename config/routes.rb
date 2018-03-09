# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :plans

  # endpoints for Slack to call
  post 'slack_sumbmission', to: 'slack_submissions#create'
  post 'slack_slash_command', to: 'slack_slash_commands#create'
end
