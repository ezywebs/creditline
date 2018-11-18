class RemoveBalanceColumn < ActiveRecord::Migration
  def self.up
    remove_column :credit_lines, :balance
  end
  
  def self.down
    add_column :credit_lines, :balance, :decimal
  end
end
