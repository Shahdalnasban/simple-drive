
Rails.application.routes.draw do
  get "/health", to: "health#show"

  namespace :v1 do
    resources :blobs, only: [ :create, :show ], param: :identifier
  end
end
