Rails.application.routes.draw do
  root "dashboards#show"

  # Routes for annoucements
  resources :announcements do 
    member do
      get :delete
    end
  end

  # TODO DELETE BOOK COLLECTION
  resources :books do 
    member do
      get :delete
    end
  end

  # Routes for committes
  resources :committees do
    member do
      get :delete
    end
  end

  # Routes for events
  resources :events do
    member do
      get :delete
    end
  end
  
  match 'calendar', to: 'announcements#calendar', via: :get

  #OATH
  devise_for :admins, controllers: { omniauth_callbacks: 'admins/omniauth_callbacks' }
  devise_scope :admin do
    get 'admins/sign_in', to: 'admins/sessions#new', as: :new_admin_session
    get 'admins/sign_out', to: 'admins/sessions#destroy', as: :destroy_admin_session
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
end
