class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :bank_name
      t.string :bank_code
      t.string :account_number
      t.string :phone_number
      t.string :unique_identifier

      t.timestamps
    end
    add_index :users, :unique_identifier, unique: true
  end
end
