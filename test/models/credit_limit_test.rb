require 'test_helper'

class CreditLimitTest < ActiveSupport::TestCase
  def setup
    @credit_line = CreditLine.new(limit: "", apr: "", date_adjust: "")
  end
  
  test "statement_date should be present" do
    assert_not @category.valid?
  end
end