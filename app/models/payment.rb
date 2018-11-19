class Payment < ActiveRecord::Base
  belongs_to :credit_line
  validates_presence_of :credit_line
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date_adjust, numericality: { only_integer: true }, :allow_nil => true
end
