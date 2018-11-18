class AddAvailableToCreditLines < ActiveRecord::Migration
  def change
    add_column :credit_lines, :available, :decimal
  end
end
