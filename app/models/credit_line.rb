class CreditLine < ActiveRecord::Base
    has_many :draws, dependent: :destroy
    validates :limit, presence: true
    validates :apr, presence: true
    validates :limit, numericality: { greater_than: 0 }
    validates :apr, numericality: { greater_than_or_equal_to: 0 }
end
