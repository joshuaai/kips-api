Rails.application.routes.draw do
  resources :categs do
    resources :lins
  end
  
  resources :products
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  namespace :api do
    namespace :v1 do
      resources :categories do
        resources :links
      end
    end
  end
  
  post 'auth/login', to: 'authentication#authenticate'
  post 'signup', to: 'users#create'
end
