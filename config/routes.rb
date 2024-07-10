Rails.application.routes.draw do
  root to: "drugs#index"

  resources :drugs
end
