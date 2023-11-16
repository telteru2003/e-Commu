Rails.application.routes.draw do

# 【管理者】 ログイン・ログアウト
  devise_for :admins, controllers: {
    sessions: 'admin/sessions'
  }

# 【ユーザー】 新規登録・ログイン・ログアウト
  devise_for :users, controllers: {
    sessions: 'public/sessions',
    passwords: 'public/passwords',
    registrations: 'public/registrations'
  }

# 【ユーザー】 ゲストログイン
  devise_scope :user do
    post "/sessions/guest_sign_in" => "public/sessions#guest_sign_in"
    resources :users, only: [:show]
  end

# ルート設定
  root 'public/homes#top'
  # resources :users
  # resources :foods

# 【ユーザー】 ログイン後のリダイレクト先
  authenticated :user do
    root 'public/foods#index', as: :authenticated_root
  end

  scope module: :public do
    resources :foods, only: [:index, :new, :create]

    # resources :families, only: [:show, :edit, :update] do
    #   get 'show', on: :member
    #   get 'edit', on: :member
    #   patch 'update/families', on: :member
    # end

    resources :families
      get 'show/families/:id', to: 'families#show', as: 'show_family'
      get 'edit/families' => 'families#edit'
      patch 'update/families' => 'families#update', as: :update_families

    resources :users, only: [:index, :show, :update, :destroy] do
      member do
        delete 'destroy', to: 'users#destroy'
      end

      # collection do
      #   get 'search_family'
      # end

    end

      get 'show/users/:id', to: 'users#show', as: 'show_user'
      get 'edit/users' => 'users#edit'
      patch 'update/users' => 'users#update', as: :update_users

      get 'quit/users', to: 'users#quit'
      patch 'out', to: 'users#out'
    end
  end
