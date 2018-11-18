class CreateCreditLimits < ActiveRecord::Migration
  def change
    create_table :credit_limits do |t|
      t.decimal :limit
      t.decimal :balance
      t.decimal :apr

      t.timestamps null: false
    end
  end
end
