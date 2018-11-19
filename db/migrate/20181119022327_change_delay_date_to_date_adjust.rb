class ChangeDelayDateToDateAdjust < ActiveRecord::Migration
  def self.up
    rename_column :draws, :delay_days, :date_adjust
  end

  def self.down
    rename_column :draws, :date_adjust, :delay_days
  end
end
