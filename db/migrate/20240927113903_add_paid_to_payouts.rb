class AddPaidToPayouts < ActiveRecord::Migration[7.1]
  def change
    add_column :payouts, :paid, :boolean, default: false
  end
end
