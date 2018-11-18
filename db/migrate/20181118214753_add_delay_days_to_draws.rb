class AddDelayDaysToDraws < ActiveRecord::Migration
  def change
    add_column :draws, :delay_days, :integer
  end
end
