module ApplicationHelper
  class Collector
    def perform
      credit_lines = CreditLine.all
      credit_lines.each do |credit_line| 
        credit_line.available = credit_line.available - 1
        credit_line.save
      end
    end
  end
end
