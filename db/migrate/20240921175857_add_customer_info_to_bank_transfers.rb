class AddCustomerInfoToBankTransfers < ActiveRecord::Migration[7.1]
  def change
    add_column :bank_transfers, :customer_name, :string
    add_column :bank_transfers, :customer_email, :string
  end
end
