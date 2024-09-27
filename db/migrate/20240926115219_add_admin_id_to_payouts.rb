class AddAdminIdToPayouts < ActiveRecord::Migration[7.1]
  def change
    add_reference :payouts, :admin, foreign_key: { to_table: :admins }, null: false
  end
end
