class CreditLine < ActiveRecord::Base
    has_many :draws, dependent: :destroy
    validates :limit, presence: true, numericality: { greater_than: 0 }
    validates :apr, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :available, numericality: true
end
