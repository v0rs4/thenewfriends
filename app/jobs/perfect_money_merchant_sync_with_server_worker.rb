class PerfectMoneyMerchantSyncWithServerWorker
	include ::Sidekiq::Worker

	def perform
		PerfectMoneyMerchant::Account.all.each(&:sync_with_pm_server)
	end
end