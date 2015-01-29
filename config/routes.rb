require 'sidekiq/web'
Rails.application.routes.draw do
	scope('auth') { devise_for :users }

	root 'static_pages#dashboard'

	resource :user_profile, only: [:edit, :update]
	resources :user_vk_contacts_files, only: [:index, :show, :update, :edit] do
		member do
			get :download
		end
	end

	get 'vkontakte_contacts_collector', to: 'static_pages#vkontakte_contacts_collector'
	get 'pricing_plans', to: 'static_pages#pricing_plans'

	scope 'vkontakte_oauth', as: :vk_o_auth do
		get 'authorize', to: 'vk_o_auth#authorize'
		get 'logout', to: 'vk_o_auth#logout'
	end

	scope 'vkontakte_contacts', as: :vkontakte_contacts do
		post 'upload', to: 'vk_contacts_load#upload_contacts'
	end

	namespace :admin do
		root 'static_pages#dashboard'
		resources :users, only: [:index, :edit, :show, :update]
		resources :perfect_money_merchant_accounts
	end

	authenticate :user do
		mount Sidekiq::Web => '/sidekiq'
	end
end
