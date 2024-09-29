class CreatePayouts < ActiveRecord::Migration[7.1]
  def change
    create_table :payouts do |t|
      t.string :reference
      t.decimal :amount
      t.string :currency
      t.string :bank_code
      t.string :account_number
      t.text :narration
      t.string :customer_name
      t.string :customer_email
      t.string :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
