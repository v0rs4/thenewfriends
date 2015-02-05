require 'sidekiq/web'
Rails.application.routes.draw do
	scope constraints: { subdomain: '' } do
		root 'tnf_landing_page#index'
	end

	scope '/auth', constraints: { subdomain: 'work' } do
		devise_for :users
	end

	scope constraints: { subdomain: 'work' }, as: :work do

		root 'static_pages#dashboard'

		resource :user_profile, only: [:edit, :update]
		resources(:user_vk_contacts_files, only: [:index, :show, :update, :edit]) { member { get :download } }

		get 'vkontakte_contacts_collector', to: 'static_pages#vkontakte_contacts_collector'
		get 'pricing_plans', to: 'static_pages#pricing_plans'
		get 'pmvf', to: 'static_pages#pmvf'
		get 'referrals', to: 'static_pages#referrals'

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
			resources :perfect_money_merchant_payments
		end

		authenticate :user do
			mount Sidekiq::Web => '/admin/sidekiq'
		end
	end
end
