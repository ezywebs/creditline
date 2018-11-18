class CreditLine < ActiveRecord::Base
    validates :limit, presence: true
    validates :apr, presence: true
    validates :limit, numericality: { greater_than: 0 }
    validates :apr, numericality: { greater_than_or_equal_to: 0 }
end
