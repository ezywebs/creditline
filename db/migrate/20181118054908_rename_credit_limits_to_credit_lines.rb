class RenameCreditLimitsToCreditLines < ActiveRecord::Migration
  def self.up
    rename_table :credit_limits, :credit_lines
  end

  def self.down
    rename_table :credit_lines, :credit_limits
  end
end
