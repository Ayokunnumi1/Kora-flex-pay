class CreateBankTransfers < ActiveRecord::Migration[7.1]
  def change
    create_table :bank_transfers do |t|
      t.string :account_name
      t.decimal :amount
      t.string :currency
      t.string :reference
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
