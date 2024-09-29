class CreateMobileMoneyTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :mobile_money_transactions do |t|
      t.decimal :amount
      t.string :currency
      t.string :customer_name
      t.string :customer_email

      t.timestamps
    end
  end
end
