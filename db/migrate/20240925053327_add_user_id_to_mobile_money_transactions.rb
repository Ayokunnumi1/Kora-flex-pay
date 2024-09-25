class AddUserIdToMobileMoneyTransactions < ActiveRecord::Migration[7.1]
  def change
    add_column :mobile_money_transactions, :user_id, :integer
  end
end
