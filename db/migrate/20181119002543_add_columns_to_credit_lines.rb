class AddColumnsToCreditLines < ActiveRecord::Migration
  def change
    add_column :credit_lines, :last_statement, :datetime
    add_column :credit_lines, :date_adjust, :integer
  end
end
