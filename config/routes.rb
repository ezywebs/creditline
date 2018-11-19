Rails.application.routes.draw do
  namespace 'api' do
    namespace 'v1' do
      resources :credit_lines
      resources :draws
      resources :payments
      post "/collector/:id" => "collector#charge"
    end
  end
  
  root :to => "welcome#index"
end