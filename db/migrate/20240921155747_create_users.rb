class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :kora_api_pk
      t.string :kora_api_sk

      t.timestamps
    end
  end
end
