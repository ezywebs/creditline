Rails.application.routes.draw do
  apipie
  namespace 'api' do
    namespace 'v1' do
      resources :credit_lines
      resources :draws
      resources :payments
      get "/collector/charge/:id" => "collector#charge"
      get "/collector/:id" => "collector#view"
    end
  end
  
  root :to => "welcome#index"
end