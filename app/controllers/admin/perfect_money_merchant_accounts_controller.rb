class Admin::PerfectMoneyMerchantAccountsController < Admin::ApplicationController
	def index
		@accounts = PerfectMoneyMerchant::Account.all
	end

	def create
		@account = PerfectMoneyMerchant::Account.new(create_params)

		respond_to do |format|
			if @account.save
				format.html { redirect_to work_admin_perfect_money_merchant_accounts_path, notice: 'Product was successfully created.' }
				# format.json { render json: @account, status: :created, location: @product }
			else
				format.html { render action: "new" }
				# format.json { render json: @account.errors, status: :unprocessable_entity }
			end
		end
	end

	def new
		@account = PerfectMoneyMerchant::Account.new.tap do |_obj|
			_obj.units.build
		end
	end

	def edit
		@account = PerfectMoneyMerchant::Account.find(params[:id]).tap do |_obj|
			_obj.units.build
		end
	end

	def update
		@account = PerfectMoneyMerchant::Account.find(params[:id])

		respond_to do |format|
			if @account.update_attributes(update_params)
				format.html { redirect_to work_admin_perfect_money_merchant_accounts_path, notice: 'Product was successfully updated.' }
				# format.json { head :no_content }
			else
				format.html { render action: "edit" }
				# format.json { render json: @account.errors, status: :unprocessable_entity }
			end
		end
	end

	def destroy

	end

	private

	def create_params
		params.require(:perfect_money_merchant_account).permit(:login, :password, :secret_key, units_attributes: [:id, :currency, :code_number])
	end

	def update_params
		params.require(:perfect_money_merchant_account).permit(:login, :password, :secret_key, units_attributes: [:id, :currency, :code_number, :_destroy])
	end
end