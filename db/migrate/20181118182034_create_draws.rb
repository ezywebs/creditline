class CreateDraws < ActiveRecord::Migration
  def change
    create_table :draws do |t|
      t.decimal :amount
      t.references :credit_line

      t.timestamps null: false
    end
  end
end
