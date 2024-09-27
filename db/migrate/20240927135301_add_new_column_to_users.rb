class AddNewColumnToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :available_balance, :decimal, precision: 15, scale: 2, default: 0.0
    add_column :users, :pending_withdraw, :decimal, precision: 15, scale: 2, default: 0.0
  end
end
