class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.decimal :amount
      t.references :credit_line
      t.integer :date_adjust

      t.timestamps null: false
    end
  end
end
