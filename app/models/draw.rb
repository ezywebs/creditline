class Draw < ActiveRecord::Base
  belongs_to :credit_line
  validates_presence_of :credit_line
  validates :amount, presence: true
  validates :amount, numericality: { greater_than: 0 }
end
