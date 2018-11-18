class Draw < ActiveRecord::Base
  belongs_to :credit_line
  validates_presence_of :credit_line
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :delay_days, numericality: { only_integer: true }, :allow_nil => true
end
